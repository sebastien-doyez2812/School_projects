import rclpy
from rclpy.node import Node
from sensor_msgs.msg import Imu
import board
import busio
import adafruit_bno055

class BNO055Node(Node):

    def __init__(self):
        super().__init__('ros_bno055')
        self.publisher_ = self.create_publisher(Imu, 'bno055_data', 10)
        self.sensor = adafruit_bno055.BNO055_I2C(busio.I2C(board.SCL, board.SDA))
        self.timer = self.create_timer(0.1, self.publish_data)

    def publish_data(self):
        imu_msg = Imu()
        imu_msg.header.frame_id = 'imubno055'
        imu_msg.header.stamp = self.get_clock().now().to_msg()
        orientation = self.sensor.euler
        imu_msg.orientation.x = orientation[0]
        imu_msg.orientation.y = orientation[1]
        imu_msg.orientation.z = orientation[2]
        angular_velocity = self.sensor.gyro
        imu_msg.angular_velocity.x = angular_velocity[0]
        imu_msg.angular_velocity.y = angular_velocity[1]
        imu_msg.angular_velocity.z = angular_velocity[2]
        linear_acceleration = self.sensor.acceleration
        imu_msg.linear_acceleration.x = linear_acceleration[0]
        imu_msg.linear_acceleration.y = linear_acceleration[1]
        imu_msg.linear_acceleration.z = linear_acceleration[2]
        self.publisher_.publish(imu_msg)

def main(args=None):
    rclpy.init(args=args)
    node = BNO055Node()
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()

if __name__ == '__main__':
    main()

