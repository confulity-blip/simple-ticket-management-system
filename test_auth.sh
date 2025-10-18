#!/bin/bash

echo "========================================"
echo "Testing Authentication Endpoints"
echo "========================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

BASE_URL="http://localhost:3000/api"

echo "1. Testing login with admin credentials..."
echo "   POST ${BASE_URL}/sessions"
RESPONSE=$(curl -s -c cookies.txt -X POST ${BASE_URL}/sessions \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@supportdesk.com","password":"password123"}')

if echo "$RESPONSE" | grep -q "Logged in successfully"; then
  echo -e "   ${GREEN}✓ Login successful${NC}"
  echo "   Response: $RESPONSE"
else
  echo -e "   ${RED}✗ Login failed${NC}"
  echo "   Response: $RESPONSE"
  exit 1
fi

echo ""
echo "2. Testing current user endpoint (with session cookie)..."
echo "   GET ${BASE_URL}/me"
RESPONSE=$(curl -s -b cookies.txt ${BASE_URL}/me)

if echo "$RESPONSE" | grep -q "admin@supportdesk.com"; then
  echo -e "   ${GREEN}✓ Current user retrieved${NC}"
  echo "   Response: $RESPONSE"
else
  echo -e "   ${RED}✗ Failed to get current user${NC}"
  echo "   Response: $RESPONSE"
  exit 1
fi

echo ""
echo "3. Testing logout..."
echo "   DELETE ${BASE_URL}/sessions"
curl -s -b cookies.txt -X DELETE ${BASE_URL}/sessions

echo -e "   ${GREEN}✓ Logged out${NC}"

echo ""
echo "4. Testing current user after logout (should fail)..."
RESPONSE=$(curl -s -b cookies.txt ${BASE_URL}/me)

if echo "$RESPONSE" | grep -q '"user":null'; then
  echo -e "   ${GREEN}✓ Correctly returns null after logout${NC}"
else
  echo -e "   ${RED}✗ Unexpected response${NC}"
  echo "   Response: $RESPONSE"
fi

echo ""
echo "5. Testing login with invalid credentials..."
RESPONSE=$(curl -s -X POST ${BASE_URL}/sessions \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@supportdesk.com","password":"wrongpassword"}')

if echo "$RESPONSE" | grep -q "Invalid email or password"; then
  echo -e "   ${GREEN}✓ Correctly rejected invalid credentials${NC}"
else
  echo -e "   ${RED}✗ Unexpected response${NC}"
  echo "   Response: $RESPONSE"
fi

echo ""
echo "========================================"
echo "All tests passed!"
echo "========================================"

# Cleanup
rm -f cookies.txt
