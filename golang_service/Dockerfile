# Use a Go base image with a compatible version
FROM golang:1.24.4 AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy the Go module files
COPY go.mod .
COPY go.sum .

# Download Go module dependencies
RUN go mod download

# Copy the source code
COPY . .

# Build the Go application
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/golang_service

# Use a lightweight base image for the final container
FROM alpine:latest

# Set the working directory
WORKDIR /root/

# Copy the compiled binary from the builder stage
COPY --from=builder /app/golang_service .

# Expose the port the Go application will listen on
EXPOSE 8081

# Command to run the application
CMD ["./golang_service"]