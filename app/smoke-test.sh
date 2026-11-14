#!/usr/bin/env bash
docker rm -f smoke 2>/dev/null
docker build -t smoke-test .
docker run -d --name smoke -p 5000:5000 smoke-test
sleep 3
CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000/)
docker rm -f smoke
if [ "$CODE" = "200" ]; then
  echo "PASS: got $CODE"
  exit 0
else
  echo "FAIL: got $CODE"
  exit 1
fi
