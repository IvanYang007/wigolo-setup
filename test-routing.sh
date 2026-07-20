#!/usr/bin/env bash
# web-search-routing skill validation — 5 scenario tests
# Run from: D:/Github/wigolo-setup/

SKILL="C:/Users/kaipi/.pi/agent/skills/web-search-routing/SKILL.md"
PASS=0; FAIL=0; TOTAL=0
RESULTS="test-routing-results.txt"

log_result() {
  TOTAL=$((TOTAL + 1))
  case "$1" in
    PASS) PASS=$((PASS + 1)); echo "  ✅ $2" ;;
    FAIL) FAIL=$((FAIL + 1)); echo "  ❌ $2" ;;
  esac
  echo "$1|$2" >> "$RESULTS"
}

echo "# Web Search Routing Test Results - $(date)" | tee "$RESULTS"
echo "" | tee -a "$RESULTS"

# ============================================================
# Scenario 1: Quick fact — "What's the latest TypeScript version?"
# Expected: web_search (simple fact, low token cost)
# ============================================================
echo "## Scenario 1: Quick Fact Lookup" | tee -a "$RESULTS"

if grep -q "Simple fact" "$SKILL" && grep -q "web_search" "$SKILL"; then
  # Verify the routing rule: simple fact → web_search
  if grep -A2 "Simple fact" "$SKILL" | grep -q "web_search"; then
    log_result "PASS" "Scenario 1: quick fact → web_search ✓"
  else
    log_result "FAIL" "Scenario 1: quick fact rule exists but doesn't point to web_search"
  fi
else
  log_result "FAIL" "Scenario 1: missing 'Simple fact' routing rule in SKILL.md"
fi

# ============================================================
# Scenario 2: Broad comparison — "Compare top Rust web frameworks"
# Expected: wigolo_search (multi-source, query arrays)
# ============================================================
echo "## Scenario 2: Broad Multi-Source Comparison" | tee -a "$RESULTS"

if grep -q "multi-source\|Broad\|comparison\|compare" "$SKILL" && grep -q "wigolo_search" "$SKILL"; then
  if grep -A3 -i "multi-source\|Broad.*comparison" "$SKILL" | grep -q "wigolo_search"; then
    log_result "PASS" "Scenario 2: broad comparison → wigolo_search ✓"
  else
    log_result "FAIL" "Scenario 2: broad comparison exists but doesn't route to wigolo_search"
  fi
else
  log_result "FAIL" "Scenario 2: missing broad multi-source routing in SKILL.md"
fi

# ============================================================
# Scenario 3: Research synthesis — "Pros and cons of Rust async runtimes"
# Expected: wigolo_research (multi-step synthesis needed)
# ============================================================
echo "## Scenario 3: Multi-Step Research Synthesis" | tee -a "$RESULTS"

if grep -q "research\|synthesis\|wigolo_research" "$SKILL"; then
  if grep -A3 -i "research.*synthesis\|Multi-step" "$SKILL" | grep -q "wigolo_research"; then
    log_result "PASS" "Scenario 3: research synthesis → wigolo_research ✓"
  else
    log_result "FAIL" "Scenario 3: research routing exists but doesn't point to wigolo_research"
  fi
else
  log_result "FAIL" "Scenario 3: missing research/synthesis routing in SKILL.md"
fi

# ============================================================
# Scenario 4: Cache hit — "What was that TypeScript page we fetched earlier?"
# Expected: wigolo_cache (repeat query, no network)
# ============================================================
echo "## Scenario 4: Repeat Query (Cache Hit)" | tee -a "$RESULTS"

if grep -q "cache\|repeat\|recent" "$SKILL" && grep -q "wigolo_cache" "$SKILL"; then
  if grep -A3 -i "repeat\|recent.*search\|cache.*first" "$SKILL" | grep -q "wigolo_cache"; then
    log_result "PASS" "Scenario 4: repeat query → wigolo_cache ✓"
  else
    log_result "FAIL" "Scenario 4: cache rule exists but doesn't route to wigolo_cache"
  fi
else
  log_result "FAIL" "Scenario 4: missing cache/repeat query routing in SKILL.md"
fi

# ============================================================
# Scenario 5: Reference docs — "How does React useEffect cleanup work?"
# Expected: ctx_fetch_and_index (index once) → ctx_search (query indexed)
# ============================================================
echo "## Scenario 5: Reference Documentation Lookup" | tee -a "$RESULTS"

if grep -q "reference\|repeated.*queries\|ctx_fetch_and_index\|ctx_search" "$SKILL"; then
  if grep -A3 -i "reference\|repeatedly" "$SKILL" | grep -q "ctx_fetch_and_index\|ctx_search"; then
    log_result "PASS" "Scenario 5: reference docs → ctx_fetch_and_index ✓"
  else
    log_result "FAIL" "Scenario 5: reference docs rule exists but doesn't route to ctx_fetch_and_index"
  fi
else
  log_result "FAIL" "Scenario 5: missing reference docs routing in SKILL.md"
fi

# ============================================================
# Additional checks
# ============================================================
echo "" | tee -a "$RESULTS"
echo "## Structural Checks" | tee -a "$RESULTS"

# Check fallbacks are documented
if grep -q "Fallback\|fallback\|FALLBACK" "$SKILL"; then
  log_result "PASS" "Structural: fallback paths documented ✓"
else
  log_result "FAIL" "Structural: missing fallback documentation"
fi

# Check anti-patterns are documented
if grep -q "ANTI-PATTERN\|anti-pattern\|Do NOT" "$SKILL"; then
  log_result "PASS" "Structural: anti-patterns documented ✓"
else
  log_result "FAIL" "Structural: missing anti-pattern documentation"
fi

# Check cache-before-network principle
if grep -q "BEFORE ANY NETWORK\|cache.*first\|before.*network" "$SKILL"; then
  log_result "PASS" "Structural: cache-before-network pattern ✓"
else
  log_result "FAIL" "Structural: missing cache-before-network guidance"
fi

# Check tool table exists
if grep -q "Tools Available\|Tool.*Provider\|tool.*token" "$SKILL"; then
  log_result "PASS" "Structural: tool comparison table ✓"
else
  log_result "FAIL" "Structural: missing tool comparison table"
fi

# ============================================================
# Summary
# ============================================================
echo "" | tee -a "$RESULTS"
echo "========================================" | tee -a "$RESULTS"
echo "  Routing Test Summary" | tee -a "$RESULTS"
echo "========================================" | tee -a "$RESULTS"
echo "  Total:   $TOTAL" | tee -a "$RESULTS"
echo "  Passed:  $PASS" | tee -a "$RESULTS"
echo "  Failed:  $FAIL" | tee -a "$RESULTS"

if [ "$FAIL" -eq 0 ]; then
  echo "" | tee -a "$RESULTS"
  echo "  ✅ ALL ROUTING TESTS PASSED — skill is valid" | tee -a "$RESULTS"
  exit 0
else
  echo "" | tee -a "$RESULTS"
  echo "  ❌ $FAIL TEST(S) FAILED — fix SKILL.md and re-test" | tee -a "$RESULTS"
  exit 1
fi
