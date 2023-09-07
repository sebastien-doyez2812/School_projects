import rclpy
from rclpy.node import Node
from sensor_msgs.msg import NavSatFix
from geometry_msgs.msg import Quaternion, Vector3
from nav_msgs.msg import Odometry
import serial
import math

class GpsNode(Node):
    def __init__(self):
        super().__init__('gps_node')
        
        # Paramètres de configuration du port série pour la réception des données GNGGA
        port = '/dev/ttyACM0' 
        baudrate = 9600
        timeout = 1

        # Ouverture du port série
        self.ser = serial.Serial(port, baudrate, timeout=timeout)

        # Initialisation du publisher sur le topic "gps_fix"
        self.publisher_ = self.create_publisher(NavSatFix, 'gps_fix', 10)

        # Initialisation du subscriber sur le topic "bno055_data"
        self.subscription = self.create_subscription(Odometry, 'bno055_data', self.imu_callback, 10)

        # Configuration du taux de publication
        self.timer_ = self.create_timer(0.1, self.publish_gps)

        # Initialisation des variables pour la fusion de données
        self.prev_lat = None
        self.prev_lon = None
        self.prev_heading = None
        self.mag_declination = 0.58/180*math.pi # Déclinaison magnétique pour la région de Paris

    def imu_callback(self, msg):
        # Récupération de l'orientation en quaternions
        q = msg.pose.pose.orientation

        # Conversion de l'orientation en radians
        roll, pitch, yaw = self.quaternion_to_euler(q.x, q.y, q.z, q.w)

        # Correction de l'angle de cap avec la déclinaison magnétique
        yaw += self.mag_declination

        # Normalisation de l'angle de cap entre -pi et pi
        yaw = math.atan2(math.sin(yaw), math.cos(yaw))

        # Sauvegarde de l'angle de cap
        self.prev_heading = yaw

    def publish_gps(self):
        # Lecture d'une ligne de données GNGGA
        line = self.ser.readline().decode('utf-8')
        if line.startswith('$GNGGA'):
            # Extraction des coordonnées GPS latitude et longitude à partir de la trame GNGGA
            parts = line.split(',')
            lat = float(parts[2])
            lon = float(parts[4])
            alt = float(parts[9])
            if self.prev_lat is not None and self.prev_lon is not None and self.prev_heading is not None:
                # Correction des coordonnées GPS avec la direction et la distance parcourues depuis la dernière position connue
                distance = self.distance(self.prev_lat, self.prev_lon, lat, lon)
                bearing = self.bearing(self.prev_lat, self.prev_lon, lat, lon)
                lat, lon = self.destination(self.prev_lat, self.prev_lon, bearing+self.prev_heading, distance)

            # Création du message NavSatFix
            msg = NavSatFix()
            msg.latitude = lat/100
            msg.longitude = lon/100
            msg.altitude = alt
            self.prev_lat = lat/100
            self.prev_lon = lon/100
           # Publication du message sur le topic "gps_fix"
            self.publisher_.publish(msg)

           

def main(args=None):
	rclpy.init(args=args)
	gps_node = GpsNode()
	rclpy.spin(gps_node)
	gps_node.destroy_node()
	rclpy.shutdown()

if __name__ == '__main__':
	main()

