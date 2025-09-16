# Layer - CDN Edge Cache System

A high-performance CDN edge caching system built with OpenResty (Nginx + Lua), Go backend, and Memcached. This system provides intelligent content caching based on geographic location and device type.

## 🏗️ Architecture

The system consists of three main components:

1. **OpenResty Proxy** - Acts as the edge cache layer with Lua-based intelligent routing
2. **Go Backend Service** - Provides the origin content service
3. **Memcached** - Distributed memory caching system

```
┌─────────────┐    ┌─────────────────┐    ┌──────────────┐    ┌─────────────┐
│   Client    │ -> │   OpenResty     │ -> │  Go Backend  │    │  Memcached  │
│             │    │  (Nginx + Lua)  │    │   Service    │    │   Cache     │
└─────────────┘    └─────────────────┘    └──────────────┘    └─────────────┘
                           │                                          ^
                           └──────────────────────────────────────────┘
```

## 🚀 Features

- **Geographic-based caching** - Different cache keys for local, European, and global users
- **Device-type optimization** - Separate caching strategies for mobile, tablet, and desktop
- **Intelligent cache miss handling** - Automatic backend fallback and cache population
- **High performance** - Lua-based logic for minimal latency
- **Containerized deployment** - Easy setup with Docker Compose

## 📋 Prerequisites

- Docker
- Docker Compose

## 🛠️ Installation & Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd layer
   ```

2. **Start the services**
   ```bash
   docker-compose up -d
   ```

3. **Verify the setup**
   ```bash
   # Check if all services are running
   docker-compose ps
   
   # Test the endpoint
   curl http://localhost:8082/
   ```

## 🔧 Configuration

### Port Configuration

- **OpenResty Proxy**: `8082` (external) -> `80` (internal)
- **Go Backend Service**: `8081`
- **Memcached**: `11211`

### Geographic Detection

The system automatically detects user location based on IP address:

- **Local**: `10.x.x.x`, `192.168.x.x`, `172.16.x.x` ranges
- **Europe**: `185.x.x.x` range
- **Global**: All other IP addresses

### Device Detection

Device types are determined from the User-Agent header:

- **Mobile**: Contains "Mobile" or "Android"
- **Tablet**: Contains "iPad"
- **Desktop**: Default for all other user agents

## 📁 Project Structure

```
layer/
├── docker-compose.yaml          # Container orchestration
├── README.md                    # Project documentation
├── openresty/                   # OpenResty configuration
│   ├── nginx.conf              # Nginx configuration
│   └── lua/
│       └── cdn_logic.lua       # CDN logic implementation
└── golang_service/             # Backend service
    ├── Dockerfile              # Go service container
    ├── go.mod                  # Go dependencies
    ├── go.sum                  # Go dependency checksums
    └── main.go                 # Main service implementation
```

## 🔄 How It Works

1. **Request Processing**: Client requests are received by OpenResty
2. **Location & Device Detection**: Lua script analyzes IP and User-Agent
3. **Cache Key Generation**: Unique cache key created using URI + location + device type
4. **Cache Lookup**: System checks Memcached for existing content
5. **Cache Hit**: If found, content is served directly with device-specific modifications
6. **Cache Miss**: Request is forwarded to Go backend, response is cached and served

## 🧪 Testing

### Basic Functionality Test
```bash
# Test basic endpoint
curl http://localhost:8082/

# Test with different User-Agent (mobile)
curl -H "User-Agent: Mozilla/5.0 (iPhone; CPU iPhone OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1" http://localhost:8082/

# Test with tablet User-Agent
curl -H "User-Agent: Mozilla/5.0 (iPad; CPU OS 14_0 like Mac OS X) AppleWebKit/605.1.15" http://localhost:8082/
```

### Cache Performance Test
```bash
# First request (cache miss)
time curl http://localhost:8082/

# Second request (cache hit)
time curl http://localhost:8082/
```

## 📊 Monitoring

### View Logs
```bash
# OpenResty logs
docker logs openresty_proxy

# Go backend logs
docker logs golang_backend

# Memcached logs
docker logs memcached_cache
```

### Cache Statistics
Connect to Memcached to view cache statistics:
```bash
docker exec -it memcached_cache telnet localhost 11211
stats
quit
```

## 🔧 Development

### Modifying the CDN Logic
Edit `openresty/lua/cdn_logic.lua` and restart the OpenResty container:
```bash
docker-compose restart openresty
```

### Updating the Backend Service
Modify `golang_service/main.go` and rebuild:
```bash
docker-compose up --build golang_service
```

## 🛡️ Security Considerations

- The system currently uses basic IP-based geographic detection
- Consider implementing proper GeoIP databases for production use
- Add authentication and rate limiting for production deployments
- Implement proper error handling and monitoring

## 📈 Performance Tuning

- Adjust cache TTL (currently 3600 seconds) in `cdn_logic.lua`
- Tune Memcached memory allocation in `docker-compose.yaml`
- Configure OpenResty worker processes based on your hardware
- Implement cache warming strategies for frequently accessed content

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📄 License

[Add your license information here]

## 🆘 Troubleshooting

### Common Issues

1. **Services not starting**: Check Docker logs and ensure ports are available
2. **Cache not working**: Verify Memcached connection in OpenResty logs
3. **Backend unreachable**: Check service linking in docker-compose.yaml

### Health Checks
```bash
# Check if backend is responding
curl http://localhost:8081/

# Check if proxy is working
curl http://localhost:8082/

# Check Memcached connectivity
telnet localhost 11211
```