
%dw 2.0
output application/json 
---
{
  "orderId": "12345",
  "customerId": "67890",
  "orderDate": "2024-01-15T10:30:00Z",
  "items": [
    {
      "productId": "9",
      "productName": "Wireless Mouse",
      "quantity": 2,
      "price": 25.99
    },
    {
      "productId": "2",
      "productName": "Wireless Mouse",
      "quantity": 2,
      "price": 25.99
    },
    {
      "productId": "6",
      "productName": "Wireless Mouse",
      "quantity": 2,
      "price": 25.99
    },
    {
      "productId": "8",
      "productName": "Wireless Mouse",
      "quantity": 10,
      "price": 25.99
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