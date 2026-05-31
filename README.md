# SPI Full-Duplex Communication

## 📖 Overview

A reusable SPI (Serial Peripheral Interface) implementation written in Verilog HDL and verified using QuestaSim.

The project demonstrates full-duplex communication between an SPI Master and SPI Slave using MOSI, MISO, SCLK, and Chip Select signals.

## ⚡ Features

* Full-duplex SPI communication
* SPI Master implementation
* SPI Slave implementation
* Top-level integration module
* Functional verification using a Verilog testbench
* Synthesizable Verilog HDL design
* Simulated and verified in QuestaSim

## 📁 Project Structure

```text
Source/
│
├── master.v      # SPI Master
├── slave.v       # SPI Slave
└── spi_top.v     # Top-level module

Testbench/
│
└── tb_spi.v      # Testbench

docs/
│
├── spi_block_diagram.png
└── spi_waveform.png
```

## 🏗️ Module Description

### master.v

Implements the SPI Master controller. Generates SCLK and CS signals and transmits data through MOSI.

### slave.v

Implements the SPI Slave controller. Receives MOSI data and transmits data through MISO.

### spi_top.v

Top-level module integrating SPI Master and SPI Slave.

### tb_spi.v

Verilog testbench used to verify SPI communication functionality.

## 🛠️ Simulation Tool

* QuestaSim

## 💻 Language

* Verilog HDL

## 📊 Results

Successful full-duplex data transfer verified through simulation.

## 👩‍💻 Author

Spurthy S
