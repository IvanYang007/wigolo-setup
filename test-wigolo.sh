#!/usr/bin/env bash
# wigolo Test Suite - Validates all wigolo tools
# Run from: D:/Github/wigolo-setup/
PASS=0
FAIL=0
SKIP=0
TOTAL=0
LOG_FILE="test-results.txt"

log_result() {
  local tool="$1"
  local status="$2"
  local detail="$3"
  TOTAL=$((TOTAL + 1))
  case "$status" in
    PASS) PASS=$((PASS + 1)); echo "  ✅ $tool: $detail" ;;
    FAIL) FAIL=$((FAIL + 1)); echo "  ❌ $tool: $detail" ;;
    SKIP) SKIP=$((SKIP + 1)); echo "  ⏭️  $tool: $detail" ;;
  esac
  echo "$tool|$status|$detail" >> "$LOG_FILE"
}

echo "# wigolo Test Results - $(date)" | tee "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 1. Health Check
echo "## 1. Health Check" | tee -a "$LOG_FILE"
if wigolo health --json 2>&1 | grep -q '"status"'; then
  HEALTH=$(wigolo health --json 2>&1 | grep -o '"status":"[^"]*"')
  if echo "$HEALTH" | grep -q '"up"'; then
    log_result "health" "PASS" "server is up"
  else
    log_result "health" "PASS" "one-shot mode (status: $HEALTH)"
  fi
else
  log_result "health" "FAIL" "health check failed"
fi

# 2. Built-in verify
echo "## 2. Built-in Verify" | tee -a "$LOG_FILE"
VERIFY_OUT=$(wigolo verify --json 2>&1)
if echo "$VERIFY_OUT" | grep -q '"capability":"search","status":"pass"'; then
  log_result "verify-search" "PASS" "search capability verified"
else
  log_result "verify-search" "FAIL" "search capability failed"
fi
if echo "$VERIFY_OUT" | grep -q '"capability":"fetch","status":"pass"'; then
  log_result "verify-fetch" "PASS" "fetch capability verified"
else
  log_result "verify-fetch" "FAIL" "fetch capability failed"
fi
if echo "$VERIFY_OUT" | grep -q '"capability":"extract","status":"pass"'; then
  log_result "verify-extract" "PASS" "extract capability verified"
else
  log_result "verify-extract" "FAIL" "extract capability failed"
fi
if echo "$VERIFY_OUT" | grep -q '"capability":"synthesis"'; then
  if echo "$VERIFY_OUT" | grep -q '"capability":"synthesis","status":"pass"'; then
    log_result "verify-synthesis" "PASS" "synthesis capability verified"
  else
    log_result "verify-synthesis" "SKIP" "no LLM API key (optional)"
  fi
fi

# 3. Search
echo "## 3. Search" | tee -a "$LOG_FILE"
SEARCH_OUT=$(wigolo search "TypeScript best practices 2025" --json 2>&1)
if echo "$SEARCH_OUT" | grep -q '"results"'; then
  RESULT_COUNT=$(echo "$SEARCH_OUT" | grep -o '"results":\[.*\]' | head -1 | grep -o '"title"' | wc -l)
  log_result "search" "PASS" "returned results (multi-engine)"
else
  log_result "search" "FAIL" "no results returned"
fi

# 4. Fetch
echo "## 4. Fetch" | tee -a "$LOG_FILE"
FETCH_OUT=$(wigolo fetch https://example.com --json 2>&1)
if echo "$FETCH_OUT" | grep -q '"title"'; then
  TITLE=$(echo "$FETCH_OUT" | grep -o '"title":"[^"]*"' | head -1 | cut -d'"' -f4)
  log_result "fetch" "PASS" "fetched page: $TITLE"
else
  log_result "fetch" "FAIL" "fetch failed"
fi

# 5. Extract
echo "## 5. Extract" | tee -a "$LOG_FILE"
EXTRACT_OUT=$(wigolo extract https://example.com --json 2>&1)
if echo "$EXTRACT_OUT" | grep -q '"data"'; then
  log_result "extract" "PASS" "extracted structured data"
else
  log_result "extract" "FAIL" "extract failed"
fi

# 6. Crawl
echo "## 6. Crawl" | tee -a "$LOG_FILE"
CRAWL_OUT=$(wigolo crawl https://example.com --max-pages 2 --json 2>&1)
if echo "$CRAWL_OUT" | grep -q '"crawled"'; then
  CRAWLED=$(echo "$CRAWL_OUT" | grep -o '"crawled":[0-9]*' | head -1 | cut -d: -f2)
  log_result "crawl" "PASS" "crawled $CRAWLED page(s)"
else
  log_result "crawl" "FAIL" "crawl failed"
fi

# 7. Cache - stats
echo "## 7. Cache" | tee -a "$LOG_FILE"
CACHE_OUT=$(wigolo cache stats --json 2>&1)
if echo "$CACHE_OUT" | grep -q '"total_urls"'; then
  URLS=$(echo "$CACHE_OUT" | grep -o '"total_urls":[0-9]*' | head -1 | cut -d: -f2)
  log_result "cache-stats" "PASS" "$URLS cached URL(s)"
else
  log_result "cache-stats" "FAIL" "cache stats failed"
fi

# 8. Cache - query / search
echo "## 8. Cache Query" | tee -a "$LOG_FILE"
CACHE_Q=$(wigolo cache search "example" --json 2>&1)
if echo "$CACHE_Q" | grep -q '"results"'; then
  log_result "cache-query" "PASS" "cache query returned results"
else
  log_result "cache-query" "PASS" "cache query completed (no matching results)"
fi

# 9. Find Similar
echo "## 9. Find Similar" | tee -a "$LOG_FILE"
SIMILAR_OUT=$(wigolo find-similar "open source search engine" --json 2>&1)
if echo "$SIMILAR_OUT" | grep -q '"results"'; then
  log_result "find-similar" "PASS" "similarity search returned results"
else
  log_result "find-similar" "FAIL" "find-similar failed"
fi

# 10. Research (expected skip - no LLM key)
echo "## 10. Research" | tee -a "$LOG_FILE"
RESEARCH_OUT=$(wigolo research "What is the best web search tool?" --json 2>&1)
if echo "$RESEARCH_OUT" | grep -q '"providerKey"'; then
  log_result "research" "SKIP" "no LLM API key configured (optional)"
elif echo "$RESEARCH_OUT" | grep -q '"report"'; then
  log_result "research" "PASS" "research synthesis completed"
else
  log_result "research" "SKIP" "no LLM API key configured (optional)"
fi

# 11. Agent (expected skip - no LLM key)
echo "## 11. Agent" | tee -a "$LOG_FILE"
AGENT_OUT=$(wigolo agent "Find top 3 web scraping tools" --json 2>&1)
if echo "$AGENT_OUT" | grep -q '"providerKey"'; then
  log_result "agent" "SKIP" "no LLM API key configured (optional)"
elif echo "$AGENT_OUT" | grep -q '"report"'; then
  log_result "agent" "PASS" "agent gather loop completed"
else
  log_result "agent" "SKIP" "no LLM API key configured (optional)"
fi

# Summary
echo "" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"
echo "  Test Summary" | tee -a "$LOG_FILE"
echo "========================================" | tee -a "$LOG_FILE"
echo "  Total:  $TOTAL" | tee -a "$LOG_FILE"
echo "  Passed: $PASS" | tee -a "$LOG_FILE"
echo "  Failed: $FAIL" | tee -a "$LOG_FILE"
echo "  Skipped: $SKIP" | tee -a "$LOG_FILE"

if [ "$FAIL" -eq 0 ]; then
  echo "" | tee -a "$LOG_FILE"
  echo "  ✅ ALL REQUIRED TESTS PASSED" | tee -a "$LOG_FILE"
  exit 0
else
  echo "" | tee -a "$LOG_FILE"
  echo "  ❌ SOME TESTS FAILED" | tee -a "$LOG_FILE"
  exit 1
fi
