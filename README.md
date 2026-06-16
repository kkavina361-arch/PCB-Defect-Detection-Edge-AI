# AI-Based PCB Defect Detection on PYNQ-Z2 FPGA

## Overview

This project implements a real-time PCB defect detection system using a YOLOv8n ONNX model deployed on the PYNQ-Z2 platform.

The system integrates Computer Vision, Edge AI, FPGA-based embedded processing, HDMI visualization, and ESP32 communication to create a complete smart PCB inspection solution.

## Features

- Real-time PCB defect detection
- YOLOv8n ONNX inference
- Edge AI deployment on PYNQ-Z2
- HDMI dashboard visualization
- USB camera integration
- ESP32 to PYNQ communication through PMODA
- Operator and production data display
- PYNQ-Z2 onboard button control
- Board count tracking
- Defect classification
- Reworkable / Non-Reworkable analysis
- Final production summary dashboard

## Defect Classes

- Mouse Bite
- Spur
- Missing Hole
- Short Circuit
- Open Circuit
- Spurious Copper

## Hardware

- PYNQ-Z2 FPGA Board
- USB Camera
- HDMI Display
- ESP32 Module

## Software

- Python
- OpenCV
- ONNX Runtime
- PYNQ Framework

## Button Controls

- BTN0 → Display operator and job data received from ESP32
- BTN1 → Live camera and defect detection
- BTN2 → PCB defect dashboard and board count display
- BTN3 → Final production summary dashboard

## Communication

Production information is transmitted from ESP32 to PYNQ-Z2 through PMODA:

- Operator Name
- Job Code
- Target Boards

## Model

- YOLOv8n
- ONNX Format
- Input Resolution: 416 × 416

## Application Workflow

ESP32 Data Input
→ Live Camera Capture
→ YOLOv8n Defect Detection
→ Defect Classification
→ HDMI Dashboard
→ Production Summary

## Future Improvements

- FPGA hardware acceleration for AI inference
- Industrial camera integration
- Cloud-based production monitoring
- Automated manufacturing inspection pipeline




