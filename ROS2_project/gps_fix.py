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
        port = '/dev/ttyACM0' # Remplacer avec le port série de votre GPS
        baudrate = 9600
        timeout = 1

        # Ouverture du port série
        self.ser = serial.Serial(port, baudrate, timeout=timeout)

        # Initialisation du publisher sur le topic "gps_fix"
        self.publisher_ = self.create_publisher(NavSatFix, 'gps_fix', 10)

        # Configuration du taux de publication
        self.timer_ = self.create_timer(0.1, self.publish_gps)

    def publish_gps(self):
        # Lecture d'une ligne de données GNGGA
        line = self.ser.readline().decode('utf-8')
        if line.startswith('$GNGGA'):
            # Extraction des coordonnées GPS latitude et longitude à partir de la trame GNGGA
            parts = line.split(',')
            lat = float(parts[2])
            lon = float(parts[4])
            alt = float(parts[9])
            # Création du message NavSatFix
            msg = NavSatFix()
            lat = lat / 100
            lon = lon /100
            decimal_lat, int_lat = math.modf(lat)
            dec_sec_lat = decimal_lat/60*100 #Pour avoir des degres secondes et pas minutes
            decimal_long, int_long = math.modf(lon)
            dec_sec_long = decimal_long/60*100 #Pour avoir des degres secondes
            #Pour avoir des degres minutes:
            #msg.latitude = lat
            #Pour avoir des degres secondes:
            msg.latitude = int_lat + dec_sec_lat
            #Pour avoir des degres minutes:
            #msg.longitude = lon
            msg.longitude = int_long + dec_sec_long
            msg.altitude = alt
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

