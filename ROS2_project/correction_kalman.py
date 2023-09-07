#!/usr/bin/env python3

import rclpy
from rclpy.node import Node
from sensor_msgs.msg import NavSatFix
from sensor_msgs.msg import Imu
from geometry_msgs.msg import PoseStamped, Vector3, Quaternion
from nav_msgs.msg import Odometry
import numpy as np
import math
import serial

class GPSIMUFusionNode(Node):
    def __init__(self):
        super().__init__('gps_imu_fusion_node')
        
        # Initialisation du filtre de Kalman
        self.state = np.zeros(4)  # [latitude, longitude, velocity_x, velocity_y]
        self.covariance = np.eye(4) * 1000
        self.R = np.array([[0.1, 0], [0, 0.1]])  # Incertitude de la mesure GPS
        self.Q = np.eye(4) * 0.01  # Incertitude du modèle de prédiction
        
        # Abonnement aux topics
        self.gps_sub = self.create_subscription(NavSatFix, 'gps_fix', self.gps_callback, 10)
        self.imu_sub = self.create_subscription(Imu, 'bno055_data', self.imu_callback, 10)
        
        # Publication des données corrigées
        self.correction_pub = self.create_publisher(NavSatFix, 'corrected_gps', 10)
        
    def quaternion_to_euler(self, x, y, z, w):
        """
        Convertit un quaternion en angles d'Euler (roulis, tangage, lacet).
        """
        if (1 - 2* (x**2 + y**2)) != 0: 
           roll = math.atan2(2 * (w * x + y * z), 1 - 2 * (x**2 + y**2))
        else:
           # pas de correction possible
           pitch = yaw= roll = 0
        if abs(2 * (w*y - z*x))< 1:
            pitch = math.asin(2 * (w * y - z * x))
        else:
            # pas de correction
            pitch = yaw = roll=  0
        if (1-2*(y**2 + z**2)) !=0:
            yaw = math.atan2(2 * (w * z + x * y), 1 - 2 * (y**2 + z**2))
        else:
            #pas de correction:
            pitch = yaw = roll= 0 
        return roll, pitch, yaw

    
    def gps_callback(self, msg):
        # Extraction des coordonnées GPS (latitude, longitude)
        latitude = msg.latitude
        longitude = msg.longitude

        
        # on utilise ici le filtre de kalman étendu:

        # Correction de l'estimation de l'état avec les mesures GPS
        #on définit la matrice de mesure:
        measurement = np.array([latitude, longitude])
        H = np.eye(2, 4)  # Matrice d'observation( on ne prend que latitude et longitude en compte)
        y = measurement - np.dot(H, self.state) # c'est l'erreur de mesure:
        #c'est la différence entre la mesure réelle et la prévision basé sur l'état actuel 
        S = np.dot(H, np.dot(self.covariance, H.T)) + self.R
        K = np.dot(np.dot(self.covariance, H.T), np.linalg.inv(S))
        self.state = self.state + np.dot(K, y) 
        self.covariance = np.dot((np.eye(4) - np.dot(K, H)), self.covariance)
        
        # Récupération de l'estimation de la position corrigée
        corrected_latitude = self.state[0]
        corrected_longitude = self.state[1]
        
        # Création du message NavSatFix corrigé
        corrected_gps_msg = NavSatFix()
        corrected_gps_msg.latitude = corrected_latitude
        corrected_gps_msg.longitude = corrected_longitude
        corrected_gps_msg.altitude = msg.altitude

        
        # Publication du message NavSatFix corrigé
        self.correction_pub.publish(corrected_gps_msg)
        
    def imu_callback(self, msg):
        # Extraction des angles d'orientation depuis l'IMU
        quaternion = (msg.orientation.x, msg.orientation.y, msg.orientation.z, msg.orientation.w)
        roll, pitch, yaw = self.quaternion_to_euler(msg.orientation.x, msg.orientation.y, msg.orientation.z, msg.orientation.w)
        
        # Mise à jour de l'estimation de l'état avec les mesures d'orientation de l'IMU
        self.state[2] = roll
        self.state[3] = pitch
        
def main(args=None):
    rclpy.init(args=args)
    node = GPSIMUFusionNode()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()

if __name__ == '__main__':
    main()
