import time
import sys
from machine import Pin, ADC, PWM

SSID = 'Wokwi-GUEST'
PASSWORD = ''

raspberry_name = None

led_verde = Pin(13, Pin.OUT)
led_amarelo = Pin(15, Pin.OUT)
led_vermelho = Pin(14, Pin.OUT)

buzzer = PWM(Pin(21))
buzzer.duty_u16(0)

sensor_a = ADC(Pin(27))
sensor_b = ADC(Pin(26))

LIMIAR_GASES_DETECTADOS_SENSOR_1 = 60000
LIMIAR_GASES_DETECTADOS_SENSOR_2 = 40000

def desligar_leds():
    led_verde.off()
    led_amarelo.off()
    led_vermelho.off()

def emitir_alarme(freq=1000, duty=32768):
    buzzer.freq(freq)
    buzzer.duty_u16(duty)

def desligar_alarme():
    buzzer.duty_u16(0)

def avaliar_ar():
    sensor_1 = sensor_a.read_u16()
    sensor_2 = sensor_b.read_u16()
    sensor_1_estado = sensor_1 > LIMIAR_GASES_DETECTADOS_SENSOR_1
    sensor_2_estado = sensor_2 > LIMIAR_GASES_DETECTADOS_SENSOR_2

    if not sensor_1_estado and not sensor_2_estado:
        return "PURO"
    elif sensor_1_estado and not sensor_2_estado:
        return "MODERADO"
    elif not sensor_1_estado and sensor_2_estado:
        return "ARRISCADO"
    elif sensor_1_estado and sensor_2_estado:
        return "EM CHAMAS"
    else:
        return "INDEFINIDO"

def sinalizar(status):
    desligar_leds()
    desligar_alarme()

    if status == "PURO":
        led_verde.on()
    elif status == "MODERADO":
        led_amarelo.on()
    elif status == "ARRISCADO":
        led_vermelho.on()
    elif status == "EM CHAMAS":
        for _ in range(3):
            led_vermelho.on()
            emitir_alarme()
            time.sleep(0.1)
            led_vermelho.off()
            desligar_alarme()
            time.sleep(0.1)
    else:
        print("Status indefinido")

def create_payload(status, raspberry_name, sensor_1, sensor_2):
    return f"Nome do dispositivo: {raspberry_name} - Status: {status} | Sensor 1: {sensor_1} - Sensor 2: {sensor_2}"

def main():
    try:
        if (raspberry_name == None):
            raspberry_name = sys.argv[1]
    except (IndexError, NameError):
        raspberry_name = input("Digite o nome do Raspberry: ")

    while True:
        status = avaliar_ar()
        sensor_1 = sensor_a.read_u16()
        sensor_2 = sensor_b.read_u16()
        print(create_payload(status, raspberry_name.upper(), sensor_1, sensor_2))
        sinalizar(status)
        time.sleep(2)

if __name__ == "__main__":
    main()

