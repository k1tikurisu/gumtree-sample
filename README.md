## Setup
```
 $ docker compose up -d
 $ docker compose exec node chmod +x scripts/jsparser
 $ docker compose exec node gumtree textdiff -f JSON src.js dst.js
```