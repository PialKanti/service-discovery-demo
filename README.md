# Service Discovery Demo

A microservices demonstration showcasing client-side service discovery using **Spring Cloud Netflix Eureka**. This project illustrates how microservices dynamically register, discover, and communicate with each other without hardcoded URLs.

---

## Table of Contents

- [About](#about)
- [Features](#features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Running the Application](#running-the-application)
- [API Reference](#api-reference)
- [Eureka Dashboard](#eureka-dashboard)
- [Testing Load Balancing](#testing-load-balancing)
- [Configuration](#configuration)
- [Contributing](#contributing)
- [License](#license)

---

## About

This project demonstrates the **client-side service discovery pattern** commonly used in microservices architecture. It consists of three services:

- **Eureka Server** - Acts as the service registry where all microservices register themselves
- **Payment Service** - A service provider that handles payment processing
- **Order Service** - A service consumer that discovers and communicates with Payment Service

The Order Service uses Eureka to dynamically discover Payment Service instances and employs client-side load balancing to distribute requests across multiple instances.

---

## Features

- **Service Registry** - Centralized Eureka server for service registration and discovery
- **Dynamic Discovery** - Services automatically register and discover each other at runtime
- **Client-Side Load Balancing** - Built-in load balancing across multiple service instances using Spring Cloud LoadBalancer
- **Health Monitoring** - Actuator endpoints for health checks and monitoring
- **Docker Support** - Multi-stage Docker builds with Docker Compose orchestration
- **Scalable Architecture** - Easily scale services by adding more instances

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      EUREKA SERVER                          │
│                    http://localhost:8761                    │
│                     Service Registry                        │
└─────────────────────────────────────────────────────────────┘
                    ▲                    ▲
                    │ register           │ register
                    │                    │
┌───────────────────┴───┐    ┌──────────┴────────────────────┐
│    PAYMENT SERVICE    │    │        ORDER SERVICE          │
│  http://localhost:8081│◄───│    http://localhost:8080      │
│  http://localhost:8082│    │                               │
│   (Multiple Instances)│    │  calls /pay via Eureka        │
└───────────────────────┘    └────────────────────────────────┘
```

**Flow:**
1. Payment Service and Order Service register with Eureka Server on startup
2. Order Service queries Eureka to discover available Payment Service instances
3. When Order Service receives a request at `/order`, it calls Payment Service's `/pay` endpoint
4. Spring Cloud LoadBalancer distributes requests across available Payment Service instances

---

## Tech Stack

| Technology | Version | Purpose |
|------------|---------|---------|
| Java | 21 | Programming Language |
| Spring Boot | 3.5.9 | Application Framework |
| Spring Cloud | 2025.0.1 | Microservices Toolkit |
| Netflix Eureka | - | Service Discovery |
| Spring Cloud LoadBalancer | - | Client-Side Load Balancing |
| Gradle | 8.14.3 | Build Tool |
| Docker | - | Containerization |
| Docker Compose | - | Container Orchestration |

---

## Prerequisites

- **Java 21** or higher
- **Gradle 8.x** (or use the included Gradle Wrapper)
- **Docker** and **Docker Compose** (for containerized deployment)

---

## Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/yourusername/service-discovery-demo.git
   cd service-discovery-demo
   ```

2. **Build the project**

   ```bash
   # Build all services
   ./gradlew build
   ```

---

## Running the Application

### Option 1: Using Docker Compose (Recommended)

The easiest way to run all services with multiple Payment Service instances:

```bash
# Build and start all services
docker-compose up --build
```

This command starts:

| Service | URL | Description |
|---------|-----|-------------|
| Eureka Server | http://localhost:8761 | Service Registry Dashboard |
| Payment Service 1 | http://localhost:8081 | First Payment Instance |
| Payment Service 2 | http://localhost:8082 | Second Payment Instance |
| Order Service | http://localhost:8080 | Order Service |

To stop all services:
```bash
docker-compose down
```

### Option 2: Using Gradle (Local Development)

Start each service in a separate terminal in the following order:

**Step 1: Start Eureka Server (must be first)**
```bash
cd eureka-server
./gradlew bootRun
```
Wait until you see: `Started EurekaServerApplication`

**Step 2: Start Payment Service (Instance 1)**
```bash
cd payment-service
./gradlew bootRun
```

**Step 3: Start Payment Service (Instance 2 - Optional)**
```bash
cd payment-service
SERVER_PORT=8082 ./gradlew bootRun
```

**Step 4: Start Order Service**
```bash
cd order-service
./gradlew bootRun
```

---

## API Reference

### Order Service

| Method | Endpoint | Description | Response |
|--------|----------|-------------|----------|
| GET | `/order` | Creates an order by calling Payment Service | Payment confirmation with port info |

**Example Request:**
```bash
curl http://localhost:8080/order
```

**Example Response:**
```
Payment from port 8081
```

### Payment Service

| Method | Endpoint | Description | Response |
|--------|----------|-------------|----------|
| GET | `/pay` | Process a payment | Confirmation with instance port |

**Example Request:**
```bash
curl http://localhost:8081/pay
```

**Example Response:**
```
Payment from port 8081
```

---

## Eureka Dashboard

Access the Eureka Dashboard to monitor registered services:

**URL:** http://localhost:8761

The dashboard displays:
- **Instances currently registered with Eureka** - List of all registered services
- **General Info** - Environment and data center information
- **Instance Info** - Detailed information about the Eureka server itself

You should see the following services registered:
- `ORDER-SERVICE` - 1 instance
- `PAYMENT-SERVICE` - 2 instances (if running with Docker Compose)

---

## Testing Load Balancing

To verify that client-side load balancing is working, run multiple requests to the Order Service:

### Using curl

```bash
# Run this command multiple times
curl http://localhost:8080/order
```

### Using a loop (Bash)

```bash
# Execute 6 requests to see load balancing in action
for i in {1..6}; do
  echo "Request $i: $(curl -s http://localhost:8080/order)"
done
```

### Expected Output

```
Request 1: Payment from port 8081
Request 2: Payment from port 8082
Request 3: Payment from port 8081
Request 4: Payment from port 8082
Request 5: Payment from port 8081
Request 6: Payment from port 8082
```

The responses alternate between ports `8081` and `8082`, demonstrating that the load balancer distributes requests across all available Payment Service instances using a round-robin strategy.

---

## Configuration

### Service Ports

| Service | Default Port | Configurable Via |
|---------|--------------|------------------|
| Eureka Server | 8761 | `server.port` |
| Payment Service | 8081 | `server.port` or `SERVER_PORT` env |
| Order Service | 8080 | `server.port` |

### Eureka Configuration

All services connect to Eureka using:
```yaml
eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
```

For Docker environments, use:
```yaml
defaultZone: http://eureka-server:8761/eureka/
```

---

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License.

```
MIT License

Copyright (c) 2025

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```
