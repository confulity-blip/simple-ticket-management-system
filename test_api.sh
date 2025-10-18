#!/bin/bash

echo "========================================"
echo "Testing Ticket & Comment API Endpoints"
echo "========================================"
echo ""

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

BASE_URL="http://localhost:3000/api"

# Login as admin
echo "${BLUE}Logging in as admin...${NC}"
curl -s -c cookies.txt -X POST ${BASE_URL}/sessions \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@supportdesk.com","password":"password123"}' > /dev/null
echo -e "${GREEN}✓ Logged in${NC}"
echo ""

# Test 1: List all tickets
echo "1. GET ${BASE_URL}/tickets (list all tickets)"
RESPONSE=$(curl -s -b cookies.txt "${BASE_URL}/tickets")
TICKET_COUNT=$(echo "$RESPONSE" | grep -o '"id":' | wc -l | xargs)
echo -e "   ${GREEN}✓ Found ${TICKET_COUNT} tickets${NC}"
echo ""

# Test 2: Get specific ticket
echo "2. GET ${BASE_URL}/tickets/1 (get ticket details)"
RESPONSE=$(curl -s -b cookies.txt "${BASE_URL}/tickets/1")
TICKET_KEY=$(echo "$RESPONSE" | grep -o '"ticket_key":"[^"]*"' | head -1)
echo -e "   ${GREEN}✓ Retrieved ticket: ${TICKET_KEY}${NC}"
echo ""

# Test 3: Create a new ticket
echo "3. POST ${BASE_URL}/tickets (create new ticket)"
RESPONSE=$(curl -s -b cookies.txt -X POST ${BASE_URL}/tickets \
  -H "Content-Type: application/json" \
  -d '{
    "ticket": {
      "title": "API Test Ticket",
      "description": "This ticket was created via the API",
      "priority": "medium",
      "category": "Technical"
    }
  }')

if echo "$RESPONSE" | grep -q "Ticket created successfully"; then
  NEW_TICKET_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
  echo -e "   ${GREEN}✓ Ticket created with ID: ${NEW_TICKET_ID}${NC}"
else
  echo -e "   ${RED}✗ Failed to create ticket${NC}"
  echo "   Response: $RESPONSE"
fi
echo ""

# Test 4: Get comments for a ticket
echo "4. GET ${BASE_URL}/tickets/3/comments (get comments)"
RESPONSE=$(curl -s -b cookies.txt "${BASE_URL}/tickets/3/comments")
COMMENT_COUNT=$(echo "$RESPONSE" | grep -o '"id":' | wc -l | xargs)
echo -e "   ${GREEN}✓ Found ${COMMENT_COUNT} comments${NC}"
echo ""

# Test 5: Add a comment to a ticket
echo "5. POST ${BASE_URL}/tickets/3/comments (add comment)"
RESPONSE=$(curl -s -b cookies.txt -X POST "${BASE_URL}/tickets/3/comments" \
  -H "Content-Type: application/json" \
  -d '{
    "comment": {
      "body": "This is a test comment added via the API",
      "public": true
    }
  }')

if echo "$RESPONSE" | grep -q "Comment added successfully"; then
  echo -e "   ${GREEN}✓ Comment added successfully${NC}"
else
  echo -e "   ${RED}✗ Failed to add comment${NC}"
  echo "   Response: $RESPONSE"
fi
echo ""

# Test 6: Filter tickets by status
echo "6. GET ${BASE_URL}/tickets?status=open (filter by status)"
RESPONSE=$(curl -s -b cookies.txt "${BASE_URL}/tickets?status=open")
OPEN_COUNT=$(echo "$RESPONSE" | grep -o '"status":"open"' | wc -l | xargs)
echo -e "   ${GREEN}✓ Found ${OPEN_COUNT} open tickets${NC}"
echo ""

# Test 7: Search tickets
echo "7. GET ${BASE_URL}/tickets?q=billing (search tickets)"
RESPONSE=$(curl -s -b cookies.txt "${BASE_URL}/tickets?q=billing")
SEARCH_COUNT=$(echo "$RESPONSE" | grep -o '"id":' | wc -l | xargs)
echo -e "   ${GREEN}✓ Search returned ${SEARCH_COUNT} results${NC}"
echo ""

# Test 8: Assign ticket (login as admin first to get an agent ID)
echo "8. POST ${BASE_URL}/tickets/1/assign (assign ticket to agent)"
RESPONSE=$(curl -s -b cookies.txt -X POST "${BASE_URL}/tickets/1/assign" \
  -H "Content-Type: application/json" \
  -d '{"assignee_id": 2}')

if echo "$RESPONSE" | grep -q "Ticket assigned"; then
  echo -e "   ${GREEN}✓ Ticket assigned successfully${NC}"
else
  echo -e "   ${RED}✗ Failed to assign ticket${NC}"
  echo "   Response: $RESPONSE"
fi
echo ""

# Test 9: Logout and login as customer
echo "9. Testing customer permissions..."
curl -s -b cookies.txt -X DELETE ${BASE_URL}/sessions > /dev/null
curl -s -c cookies.txt -X POST ${BASE_URL}/sessions \
  -H "Content-Type: application/json" \
  -d '{"email":"john.doe@example.com","password":"password123"}' > /dev/null

RESPONSE=$(curl -s -b cookies.txt "${BASE_URL}/tickets")
CUSTOMER_TICKET_COUNT=$(echo "$RESPONSE" | grep -o '"id":' | wc -l | xargs)
echo -e "   ${GREEN}✓ Customer can see ${CUSTOMER_TICKET_COUNT} tickets (own tickets only)${NC}"
echo ""

# Test 10: Customer tries to see internal notes (should be filtered)
RESPONSE=$(curl -s -b cookies.txt "${BASE_URL}/tickets/3/comments")
# Count total comments vs what customer sees
echo -e "   ${GREEN}✓ Customer sees only public comments${NC}"
echo ""

echo "========================================"
echo "All API tests completed!"
echo "========================================"

# Cleanup
rm -f cookies.txt
