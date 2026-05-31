# SPI Full-Duplex Communication

## Overview

This project implements the Serial Peripheral Interface (SPI) protocol in Verilog HDL. The design includes SPI Master and SPI Slave modules capable of full-duplex data transfer.

The project was developed and verified using QuestaSim.

## Features

* Full-duplex SPI communication
* Master and Slave implementation
* Top-level integration module
* Functional verification using a testbench
* Simulation support in QuestaSim

## Project Structure

SPI-Full-Duplex/

├── Source/

│ ├── master.v

│ ├── slave.v

│ └── spi_top.v

├── Testbench/

│ └── tb_spi.v

├── docs/

│ ├── spi_block_diagram.png

│ └── spi_waveform.png

├── README.md

└── .gitignore

## Modules

### master.v

Implements the SPI Master controller responsible for generating the SPI clock, chip-select signal, and transmitting data over MOSI.

### slave.v

Implements the SPI Slave controller responsible for receiving data from MOSI and transmitting data through MISO.

### spi_top.v

Top-level module connecting the SPI Master and SPI Slave modules.

### tb_spi.v

Testbench used for functional verification of SPI communication.

## Simulation Tool

* QuestaSim

## Language

* Verilog HDL

## Results

Successful full-duplex data transfer was verified through simulation.

## Author

Spurthy S
