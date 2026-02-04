#define __MICROBLAZE__
#include "xparameters.h"
#include "xuartlite.h"
#include "xiic.h"
#include "xgpio.h"
#include "xstatus.h"
#include "xilic.h"
#include "xil_printf.h"
#include "sleep.h"
#include <math.h>

// Instância dos módulos UARTLITE e IIC
XUartLite UARTLITE_0;
XIic IIC_0;

// Definição do periférico MPU-6050
#define MPU6050_ADDR      0x68

// Registradores do sensor MPU-6050
#define WHO_I_AM          0x75
#define PWR_MGMT_1        0x6B
#define ACCEL_XOUT_H      0x3B

// Funções auxiliares para o sensor MPU-6050
int MPU6050_WriteReg(u8 reg, u8 value) {
    u8 buf[2] = {reg, value};
    return XIic_Send(XPAR_XIIC_0_BASEADDR, MPU6050_ADDR, buf, 2, XIIC_STOP);
}

int MPU6050_ReadReg(u8 reg, u8 *recv_value) {
    XIic_Send(XPAR_XIIC_0_BASEADDR, MPU6050_ADDR, &reg, 1, XIIC_REPEATED_START);
    return XIic_Recv(XPAR_XIIC_0_BASEADDR, MPU6050_ADDR, recv_value, 1, XIIC_STOP);
}

int MPU6050_ReadSeqRegs(u8 reg, u8 *recv_buffer, int length) {
    XIic_Send(XPAR_XIIC_0_BASEADDR, MPU6050_ADDR, &reg, 1, XIIC_REPEATED_START);
    return XIic_Recv(XPAR_XIIC_0_BASEADDR, MPU6050_ADDR, recv_buffer, length, XIIC_STOP);
}

int MPU6050_Init() {
    int MPU6050_Status;

    // Reset do sensor
    MPU6050_Status = MPU6050_WriteReg(PWR_MGMT_1, 0x00);
    if (MPU6050_Status == 0) {
        return XST_FAILURE;
    }
    msleep(100);
    return XST_SUCCESS;
}

// Função principal
int main() {
    u8 sensor_id;

    // Aceleração (6 bytes), Temperatura (2 bytes), Giroscópio (6 bytes)
    u8 data_buf[14];
    s16 ax_raw, ay_raw, az_raw, tp_raw, gx_raw, gy_raw, gz_raw;
    float ax, ay, az, tp, gx, gy, gz;

    // Inicializações
    XIic_Config *ConfigPtr;
    int Status;

    ConfigPtr = XIic_LookupConfig(XPAR_XIIC_0_BASEADDR);
    if (ConfigPtr == NULL) {
        return XST_FAILURE;
    }

    Status = XIic_CfgInitialize(&IIC_0, ConfigPtr, ConfigPtr->BaseAddress);
    if (Status != XST_SUCCESS) {
        xil_printf("Falha na inicialização do módulo Iic.\r\n");
    }

    Status = XUartLite_Initialize(&UARTLITE_0, XPAR_AXI_UARTLITE_0_BASEADDR);
    if (Status != XST_SUCCESS) {
        xil_printf("Falha na inicialização do módulo UartLite.\r\n");
    }

    MPU6050_Init();

    MPU6050_ReadReg(WHO_I_AM, &sensor_id);
    xil_printf("Who am I: %d\r\n", sensor_id);
    msleep(2000);

    while(1) {
        // Ler os 14 bytes: aceleração, temperatura e giroscópio
        MPU6050_ReadSeqRegs(ACCEL_XOUT_H, data_buf, 14);

        ax_raw = (data_buf[0] << 8) | data_buf[1];
        ay_raw = (data_buf[2] << 8) | data_buf[3];
        az_raw = (data_buf[4] << 8) | data_buf[5];
        tp_raw = (data_buf[6] << 8) | data_buf[7];
        gx_raw = (data_buf[8] << 8) | data_buf[9];
        gy_raw = (data_buf[10] << 8) | data_buf[11];
        gz_raw = (data_buf[12] << 8) | data_buf[13];

        // Conversões físicas
        ax = ((float)ax_raw / 16384.0f) * 9.80665f;
        ay = ((float)ay_raw / 16384.0f) * 9.80665f;
        az = ((float)az_raw / 16384.0f) * 9.80665f;
        tp = ((float)tp_raw / 340.0f) + 36.53f;
        gx = ((float)gx_raw / 131.0f);
        gy = ((float)gy_raw / 131.0f);
        gz = ((float)gz_raw / 131.0f);

        xil_printf("Ax: %d.%02d m/s², Ay: %d.%02d m/s², Az: %d.%02d m/s²\r\n",
            (int)ax, abs((int)((ax-(int)ax) * 100)),
            (int)ay, abs((int)((ay-(int)ay) * 100)),
            (int)az, abs((int)((az-(int)az) * 100))
        );
        xil_printf("Tp: %d.%02d °C\r\n",
            (int)tp, abs((int)((tp-(int)tp) * 100))
        );
        xil_printf("Gx: %d.%02d °/s, Gy: %d.%02d °/s, Gz: %d.%02d °/s\r\n",
            (int)gx, abs((int)((gx-(int)gx) * 100)),
            (int)gy, abs((int)((gy-(int)gy) * 100)),
            (int)gz, abs((int)((gz-(int)gz) * 100))
        );

        msleep(200);
    }

    XIic_Stop(&IIC_0);
}
