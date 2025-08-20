# Specialized Cargo and Freight Services System

A comprehensive blockchain-based system for managing specialized cargo and freight operations using Clarity smart contracts on the Stacks blockchain.

## Overview

This system provides end-to-end management for specialized cargo transport, including temperature-controlled shipments, hazardous materials, and high-value freight. It ensures regulatory compliance, real-time monitoring, and comprehensive documentation throughout the supply chain.

## Key Features

### 🌡️ Temperature Control Management
- Real-time temperature monitoring and alerts
- Automated compliance checking for temperature-sensitive cargo
- Historical temperature data logging
- Integration with IoT sensors and monitoring devices

### ⚠️ Hazardous Materials Handling
- Classification and tracking of hazmat cargo
- Safety protocol enforcement and documentation
- Regulatory compliance verification
- Emergency response coordination

### 🔒 Security and Monitoring
- Real-time cargo location tracking
- Security breach detection and alerts
- Chain of custody documentation
- Access control and authorization management

### 📋 Regulatory Compliance
- Automated compliance checking against regulations
- Documentation generation and storage
- Audit trail maintenance
- Certification and permit management

### 🛡️ Insurance Coordination
- Automated claim processing workflows
- Risk assessment and premium calculations
- Coverage verification and validation
- Incident reporting and documentation

## Smart Contract Architecture

The system consists of five interconnected Clarity smart contracts:

1. **Core Cargo Contract** (`cargo-core.clar`)
    - Central cargo registration and management
    - Shipment lifecycle tracking
    - Basic cargo information storage

2. **Temperature Control Contract** (`temperature-control.clar`)
    - Temperature monitoring and logging
    - Alert generation for temperature violations
    - Compliance verification for temperature-sensitive goods

3. **Hazmat Safety Contract** (`hazmat-safety.clar`)
    - Hazardous material classification and tracking
    - Safety protocol enforcement
    - Emergency response coordination

4. **Insurance Contract** (`insurance.clar`)
    - Policy management and coverage verification
    - Automated claim processing
    - Risk assessment and premium calculations

5. **Compliance Contract** (`compliance.clar`)
    - Regulatory requirement tracking
    - Documentation management
    - Audit trail maintenance

## Data Types and Structures

### Cargo Information
- Unique cargo ID and tracking number
- Origin and destination details
- Cargo type, weight, and dimensions
- Special handling requirements
- Current status and location

### Temperature Data
- Real-time temperature readings
- Acceptable temperature ranges
- Alert thresholds and notifications
- Historical temperature logs

### Safety Protocols
- Hazmat classification codes
- Required safety equipment
- Emergency contact information
- Incident reporting procedures

### Compliance Records
- Regulatory requirements checklist
- Certification and permit status
- Audit logs and documentation
- Violation tracking and resolution

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm
- Stacks wallet for testing

### Installation
\`\`\`bash
npm install
clarinet check
clarinet test
\`\`\`

### Testing
\`\`\`bash
npm test
\`\`\`

### Deployment
\`\`\`bash
clarinet deploy --testnet
\`\`\`

## Usage Examples

### Registering New Cargo
```clarity
(contract-call? .cargo-core register-cargo 
  "CARGO001" 
  "Electronics" 
  u1000 
  "New York" 
  "Los Angeles" 
  (some "temperature-controlled"))
