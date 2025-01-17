# Detailed Documentation for Uzon Real-Time Order Processing System

## Overview
This documentation outlines the implementation of a **Uzon Real-Time Order Processing System** using MuleSoft APIs integrated with Apache Kafka (hosted on Aiven) for messaging and MySQL (hosted on Aiven) for data persistence. The system uses Okta OIDC OAuth for authentication and Kafka ACLs (SASL SCRAM) for secure communication.

---

## Architecture Overview

### Components
1. **MuleSoft**:
   - Acts as the API gateway to expose RESTful endpoints.
   - Handles Kafka message publishing and consumption.
2. **Apache Kafka (Aiven)**:
   - Facilitates high-throughput, real-time messaging for order processing.
3. **MySQL (Aiven)**:
   - Stores order details, inventory data, and customer information.
4. **Okta OIDC OAuth**:
   - Provides secure authentication for API endpoints.
5. **Kafka ACLs with SASL SCRAM**:
   - Ensures role-based access to Kafka topics.

### Data Flow
1. **Order Ingestion**: Orders are submitted via REST API and published to Kafka (`orders-in` topic).
2. **Validation & Processing**: Kafka consumers validate, process orders, and update their status in the database.
3. **Order Status Query**: Real-time order status is fetched from the database via REST API.

---

## Key Features

### 1. API Endpoints
| **Method** | **Endpoint**            | **Description**                              |
|------------|-------------------------|----------------------------------------------|
| `POST`     | `/api/orders`           | Accept new orders and publish to Kafka.      |
| `GET`      | `/api/orders/{id}`      | Retrieve real-time status of an order.       |

### 2. Kafka Topics
| **Topic**            | **Purpose**                                                    |
|-----------------------|----------------------------------------------------------------|
| `orders-in`          | Ingest new orders from the API.                                |
| `orders-validated`   | Store validated orders after processing.                       |
| `order-status`       | Publish real-time order status updates (e.g., "Placed").       |
| `inventory-updates`  | Notify inventory systems about changes in stock levels.        |
| `shipping-updates`   | Notify shipping systems about new orders to ship.              |

### 3. Database Summary
- **Product Inventory**: Tracks product details, stock levels, and pricing.
- **Orders**: Stores order details, customer information, and shipping addresses.
- **Order Items**: Captures details of individual items in each order.
- **Order Status**: Maintains a history of status changes for each order.
- **Customers**: Stores customer information, including contact details.

---

## Implementation Details

### 1. API Design
- **Order Ingestion Flow**:
  - Validate incoming order payloads.
  - Publish the order to Kafka’s `orders-in` topic.
- **Order Status Query Flow**:
  - Query the database for the latest status of the requested order.
  - Return the status with minimal latency.

### 2. Kafka Integration
- **Producer**:
  - Publishes orders to `orders-in` topic.
  - Configured with `acks=all` for reliable delivery.
  - Uses order ID as the partition key for consistent ordering.
- **Consumer**:
  - Consumes messages from `orders-in` and `orders-validated` topics.
  - Implements manual offset commits for precise control.

### 3. Security
- **API Authentication**:
  - Secured using **Okta OIDC OAuth** with role-based access control.
  - Scopes:
    - `orders.read` for querying order statuses.
    - `orders.write` for creating new orders.
- **Kafka ACLs**:
  - Configured using SASL SCRAM.
  - Producers and consumers have restricted topic-level access based on roles.

### 4. Error Handling
- Retry failed Kafka deliveries using MuleSoft’s retry policies.
- Messages that cannot be processed are sent to a **Dead Letter Queue (DLQ)** topic (`dlq-orders`).

### 5. Monitoring
- **MuleSoft**:
  - Monitored using **Anypoint Monitoring** for API metrics (e.g., response time, throughput).
- **Kafka**:
  - Topic lag and consumer health tracked using tools like Prometheus and Grafana.
- **Database**:
  - Monitored for query performance and latency using Aiven tools.

---

## Deployment on CloudHub

### CPU and Memory Allocation
- **Memory**: Start with **4 GB**, scale to **8 GB** for high traffic.
- **CPU**: Allocate **2 vCores**, scale to **4 vCores** for heavy workloads.

### Scaling
- **Horizontal Scaling**: Add more workers to handle increased load.
- **Vertical Scaling**: Increase memory and CPU allocation as needed.

---

## Performance Optimization

### Reduce API Response Time
1. Implement asynchronous processing for order ingestion.
2. Use caching for frequently accessed order statuses.

### Optimize Kafka
1. Use consumer groups for message consumers.
2. Scale consumer groups for better load distribution.

### Optimize Database
1. Add indexes on frequently queried fields such as `OrderId` and `Status`.
2. Optimize queries to minimize latency.

---

## **Database Schema**

### **Tables**

1. **`Customers`**
   - Stores customer details.
   ```
   Columns: CustomerId, CustomerName, Email, Phone
   ```

2. **`Orders`**
   - Stores order information.
   ```
   Columns: OrderId, CustomerId, OrderDate, TotalAmount, PaymentStatus, OrderStatus, ShippingAddressId
   ```

3. **`OrderItems`**
   - Stores details of items in each order.
   ```
   Columns: OrderId, ProductId, ProductName, Quantity, Price
   ```

4. **`ShippingAddresses`**
   - Stores shipping addresses associated with orders.
   ```
   Columns: AddressId, Street, City, State, ZipCode, Country
   ```

5. **`ProductInventory`**
   - Maintains inventory of products.
   ```
   Columns: ProductID,	ProductName,	Description,	QuantityInStock,	ReorderLevel,	PricePerUnit,	LastRestockDate,	CreatedAt,	UpdatedAt,	IsActive
   ```

6. **`OrderStatus`**
   - Tracks the status of orders.
   ```
   Columns: OrderId, Status, Timestamp
   ```

---

## **JSON Schemas**

### **Order Request JSON**
```json
{
  "orderId": "12345",
  "customerId": "67890",
  "customerName": "John Doe",
  "customerEmail": "john.doe@example.com",
  "customerPhone": "+1-555-1234",
  "orderDate": "2024-01-15T10:30:00Z",
  "items": [
    {
      "productId": "P001",
      "productName": "Wireless Mouse",
      "quantity": 2,
      "price": 25.99
    },
    {
      "productId": "P002",
      "productName": "Keyboard",
      "quantity": 1,
      "price": 49.99
    }
  ],
  "totalAmount": 101.97,
  "paymentStatus": "Paid",
  "orderStatus": "New",
  "shippingAddress": {
    "street": "123 Elm Street",
    "city": "San Francisco",
    "state": "CA",
    "zipCode": "94101",
    "country": "USA"
  }
}
```

### **Order Status JSON**
```json
{
  "orderId": "12345",
  "currentStatus": "Shipped",
  "statusDetails": [
    {
      "status": "Packed",
      "timeStamp": "02:00:00 PM, January 15, 2024"
    },
    {
      "status": "Shipped",
      "timeStamp": "03:00:00 PM, January 15, 2024"
    }
  ]
}
```

### **Inventory Update JSON**
```json
{
  "productId": "P001",
  "productName": "Wireless Mouse",
  "quantityDeducted": 2,
  "remainingStock": 98,
  "updateTimestamp": "2024-01-15T10:45:00Z",
  "orderId": "12345"
}

