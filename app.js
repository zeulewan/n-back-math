const elements = {
  body: document.body,
  gameTab: document.getElementById("game-tab"),
  statsTab: document.getElementById("stats-tab"),
  gameView: document.getElementById("game-view"),
  statsView: document.getElementById("stats-view"),
  levelDownButton: document.getElementById("level-down-btn"),
  levelUpButton: document.getElementById("level-up-btn"),
  levelValue: document.getElementById("level-value"),
  startButton: document.getElementById("start-btn"),
  clearButton: document.getElementById("clear-btn"),
  clearProgressButton: document.getElementById("clear-progress-btn"),
  phaseBadge: document.getElementById("phase-badge"),
  resultBadge: document.getElementById("result-badge"),
  timerFill: document.getElementById("timer-fill"),
  problemDisplay: document.getElementById("problem-display"),
  answerValue: document.getElementById("answer-value"),
  keypad: document.getElementById("keypad"),
  roundCount: document.getElementById("round-count"),
  finishSummary: document.getElementById("finish-summary"),
  correctCount: document.getElementById("correct-count"),
  missedCount: document.getElementById("missed-count"),
  accuracyCount: document.getElementById("accuracy-count"),
  lifetimeRuns: document.getElementById("lifetime-runs"),
  lifetimeAccuracy: document.getElementById("lifetime-accuracy"),
  bestAccuracy: document.getElementById("best-accuracy"),
  bestStreak: document.getElementById("best-streak"),
  storedLevelLabel: document.getElementById("stored-level-label"),
  recentCount: document.getElementById("recent-count"),
  levelMap: document.getElementById("level-map"),
  historyList: document.getElementById("history-list"),
};

const KEY_LAYOUT = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"];
const MAX_N_BACK = 12;
const TOTAL_ROUNDS = 24;
const STORAGE_KEY = "nBackMath.progress.v2";
const MAX_SAVED_RUNS = 80;

const LEVELS = Array.from({ length: MAX_N_BACK * 2 }, (_, index) => {
  const nBack = Math.floor(index / 2) + 1;
  const isFast = index % 2 === 1;
  const speedLabel = isFast ? "Fast" : "Slow";

  return {
    index,
    id: `${speedLabel.toLowerCase()}-${nBack}`,
    nBack,
    speedLabel,
    answerMs: isFast ? 3000 : 4000,
  };
});

const state = {
  activeView: "game",
  gameActive: false,
  acceptingAnswer: false,
  phase: "idle",
  levelIndex: 0,
  nBack: 1,
  answerMs: 4000,
  displayStep: 0,
  round: 0,
  problems: [],
  currentProblem: null,
  currentTarget: null,
  currentAnswer: "",
  answeredQuestions: 0,
  correct: 0,
  missed: 0,
  streak: 0,
  maxStreak: 0,
  lastOutcome: null,
  runStartedAt: null,
  timers: [],
  timerAnimation: null,
  progress: createDefaultProgress(),
};

function init() {
  state.progress = loadProgress();
  state.levelIndex = clampLevelIndex(state.progress.levelIndex);
  buildKeypad();
  bindEvents();
  applyLevelSettings();
  render();
}

function createDefaultProgress() {
  return {
    version: 2,
    levelIndex: 0,
    runs: [],
  };
}

function loadProgress() {
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    if (!raw) {
      return createDefaultProgress();
    }

    const parsed = JSON.parse(raw);
    const progress = createDefaultProgress();
    progress.levelIndex = clampLevelIndex(Number(parsed.levelIndex) || 0);
    progress.runs = Array.isArray(parsed.runs)
      ? parsed.runs.filter(isValidRun).slice(0, MAX_SAVED_RUNS)
      : [];
    return progress;
  } catch {
    return createDefaultProgress();
  }
}

function isValidRun(run) {
  return (
    run &&
    typeof run === "object" &&
    Number.isFinite(run.levelIndex) &&
    run.levelIndex >= 0 &&
    run.levelIndex < LEVELS.length &&
    Number.isFinite(run.correct) &&
    Number.isFinite(run.missed)
  );
}

function saveProgress() {
  state.progress.levelIndex = state.levelIndex;
  window.localStorage.setItem(STORAGE_KEY, JSON.stringify(state.progress));
}

function buildKeypad() {
  KEY_LAYOUT.forEach((token) => {
    elements.keypad.append(createKey(token));
  });
}

function createKey(token) {
  const button = document.createElement("button");
  button.type = "button";
  button.className = "key";
  button.dataset.value = token;
  button.textContent = token;
  button.disabled = true;

  if (token === "0") {
    button.classList.add("zero");
  }

  button.addEventListener("click", () => appendDigit(token));
  return button;
}

function bindEvents() {
  elements.gameTab.addEventListener("click", () => setView("game"));
  elements.statsTab.addEventListener("click", () => setView("stats"));
  elements.levelDownButton.addEventListener("click", () => adjustLevel(-1));
  elements.levelUpButton.addEventListener("click", () => adjustLevel(1));
  elements.startButton.addEventListener("click", handlePrimaryAction);
  elements.clearButton.addEventListener("click", clearAnswer);
  elements.clearProgressButton.addEventListener("click", clearProgress);

  window.addEventListener("keydown", (event) => {
    if (event.key === "ArrowLeft" && !state.gameActive) {
      adjustLevel(-1);
      return;
    }

    if (event.key === "ArrowRight" && !state.gameActive) {
      adjustLevel(1);
      return;
    }

    if (!state.acceptingAnswer || state.activeView !== "game") {
      return;
    }

    if (/^[0-9]$/.test(event.key)) {
      appendDigit(event.key);
      return;
    }

    if (event.key === "Backspace") {
      clearAnswer();
    }
  });
}

function handlePrimaryAction() {
  if (isResetState()) {
    resetGame();
    return;
  }

  startGame();
}

function setView(viewName) {
  if (viewName === "stats" && state.gameActive) {
    return;
  }

  state.activeView = viewName;
  render();
}

function adjustLevel(delta) {
  if (state.gameActive) {
    return;
  }

  const nextIndex = clampLevelIndex(state.levelIndex + delta);
  if (nextIndex === state.levelIndex) {
    return;
  }

  state.levelIndex = nextIndex;
  applyLevelSettings();
  saveProgress();
  pulseElement(elements.levelValue);
  render();
}

function clampLevelIndex(index) {
  return Math.min(Math.max(index, 0), LEVELS.length - 1);
}

function applyLevelSettings() {
  const level = LEVELS[state.levelIndex];
  state.nBack = level.nBack;
  state.answerMs = level.answerMs;
}

function startGame() {
  clearAllTimers();
  stopTimerBar();
  applyLevelSettings();
  saveProgress();
  state.activeView = "game";
  state.gameActive = true;
  state.acceptingAnswer = false;
  state.phase = "ready";
  state.displayStep = 0;
  state.round = 0;
  state.problems = [];
  state.currentProblem = null;
  state.currentTarget = null;
  state.currentAnswer = "";
  state.answeredQuestions = 0;
  state.correct = 0;
  state.missed = 0;
  state.streak = 0;
  state.maxStreak = 0;
  state.lastOutcome = null;
  state.runStartedAt = Date.now();

  setProblem("Ready");
  render();
  queue(nextRound, 700);
}

function resetGame() {
  clearAllTimers();
  state.gameActive = false;
  stopTimerBar();
  state.acceptingAnswer = false;
  state.phase = "idle";
  state.displayStep = 0;
  state.round = 0;
  state.problems = [];
  state.currentProblem = null;
  state.currentTarget = null;
  state.currentAnswer = "";
  state.answeredQuestions = 0;
  state.correct = 0;
  state.missed = 0;
  state.streak = 0;
  state.maxStreak = 0;
  state.lastOutcome = null;
  state.runStartedAt = null;

  setProblem("N-Back Math");
  render();
}

function nextRound() {
  if (state.answeredQuestions >= TOTAL_ROUNDS) {
    finishGame();
    return;
  }

  state.displayStep += 1;
  state.currentAnswer = "";
  state.currentProblem = buildProblem();
  state.problems.push(state.currentProblem);
  state.currentTarget = null;

  setProblem(formatProblem(state.currentProblem), true);
  startTimerBar(state.answerMs);

  if (state.displayStep <= state.nBack) {
    state.phase = "memorize";
    state.acceptingAnswer = false;
    render();
    queue(nextRound, state.answerMs);
    return;
  }

  state.phase = "answering";
  state.acceptingAnswer = true;
  state.currentTarget = state.problems[state.displayStep - state.nBack - 1];
  state.round = state.answeredQuestions + 1;
  render();
  queue(submitAnswer, state.answerMs);
}

function buildProblem() {
  const left = randomInt(9);
  const right = randomInt(9);

  if (Math.random() < 0.5) {
    const high = Math.max(left, right);
    const low = Math.min(left, right);
    return {
      left: high,
      operator: "-",
      right: low,
      answer: high - low,
    };
  }

  return {
    left,
    operator: "+",
    right,
    answer: left + right,
  };
}

function randomInt(max) {
  return Math.floor(Math.random() * (max + 1));
}

function formatProblem(problem) {
  return `${problem.left} ${problem.operator} ${problem.right}`;
}

function appendDigit(digit) {
  if (!state.acceptingAnswer) {
    return;
  }

  if (state.currentAnswer === "0") {
    state.currentAnswer = digit;
  } else if (state.currentAnswer.length >= 2) {
    return;
  } else {
    state.currentAnswer += digit;
  }

  if (Number(state.currentAnswer) === state.currentTarget.answer) {
    submitAnswer();
    return;
  }

  render();
}

function clearAnswer() {
  if (!state.acceptingAnswer) {
    return;
  }

  state.currentAnswer = "";
  render();
}

function submitAnswer() {
  if (!state.acceptingAnswer || !state.currentTarget) {
    return;
  }

  clearAllTimers();
  stopTimerBar();
  state.acceptingAnswer = false;
  state.answeredQuestions += 1;
  state.round = state.answeredQuestions;

  const raw = state.currentAnswer.trim();
  const parsed = raw === "" ? null : Number(raw);
  const isCorrect = parsed === state.currentTarget.answer;
  state.currentAnswer = "";

  if (isCorrect) {
    state.correct += 1;
    state.streak += 1;
    state.maxStreak = Math.max(state.maxStreak, state.streak);
    state.lastOutcome = "correct";
  } else {
    state.missed += 1;
    state.streak = 0;
    state.lastOutcome = "wrong";
  }

  nextRound();
}

function finishGame() {
  state.gameActive = false;
  state.acceptingAnswer = false;
  state.phase = "finished";
  stopTimerBar();
  setProblem("Done");
  recordRun();
  render();
}

function recordRun() {
  const level = LEVELS[state.levelIndex];
  const run = {
    id: `${Date.now()}-${Math.random().toString(16).slice(2)}`,
    completedAt: new Date().toISOString(),
    levelIndex: state.levelIndex,
    levelId: level.id,
    levelLabel: formatLevel(level),
    nBack: level.nBack,
    speedLabel: level.speedLabel,
    answerMs: level.answerMs,
    rounds: TOTAL_ROUNDS,
    correct: state.correct,
    missed: state.missed,
    accuracy: calculateAccuracy(state.correct, TOTAL_ROUNDS),
    bestStreak: state.maxStreak,
    durationMs: state.runStartedAt ? Date.now() - state.runStartedAt : 0,
  };

  state.progress.runs.unshift(run);
  state.progress.runs = state.progress.runs.slice(0, MAX_SAVED_RUNS);
  saveProgress();
}

function clearProgress() {
  if (state.gameActive) {
    return;
  }

  const shouldClear = window.confirm(
    "Clear saved level, run history, and stats from this browser?",
  );
  if (!shouldClear) {
    return;
  }

  state.progress = createDefaultProgress();
  state.levelIndex = 0;
  applyLevelSettings();
  saveProgress();
  resetGame();
  state.activeView = "stats";
  render();
}

function queue(callback, delay) {
  const timer = window.setTimeout(() => {
    state.timers = state.timers.filter((id) => id !== timer);
    callback();
  }, delay);
  state.timers.push(timer);
}

function clearAllTimers() {
  state.timers.forEach((timer) => window.clearTimeout(timer));
  state.timers = [];
}

function startTimerBar(duration) {
  stopTimerBar();
  elements.timerFill.style.transition = "none";
  elements.timerFill.style.transform = "scaleX(1)";

  state.timerAnimation = window.requestAnimationFrame(() => {
    elements.timerFill.style.transition = `transform ${duration}ms linear`;
    elements.timerFill.style.transform = "scaleX(0)";
    state.timerAnimation = null;
  });
}

function stopTimerBar() {
  if (state.timerAnimation !== null) {
    window.cancelAnimationFrame(state.timerAnimation);
    state.timerAnimation = null;
  }

  elements.timerFill.style.transition = "none";
  elements.timerFill.style.transform = state.gameActive
    ? "scaleX(0)"
    : "scaleX(1)";
}

function setProblem(value, flash = false) {
  elements.problemDisplay.textContent = value;
  elements.problemDisplay.classList.toggle("flash", false);
  if (flash) {
    requestAnimationFrame(() => {
      elements.problemDisplay.classList.add("flash");
    });
  }
}

function render() {
  const level = LEVELS[state.levelIndex];
  const currentAccuracy = calculateAccuracy(
    state.correct,
    Math.max(state.answeredQuestions, 1),
  );
  const progressStats = buildProgressStats();

  elements.body.classList.toggle("playing", state.gameActive);
  elements.gameTab.classList.toggle("active", state.activeView === "game");
  elements.statsTab.classList.toggle("active", state.activeView === "stats");
  elements.gameTab.setAttribute(
    "aria-selected",
    String(state.activeView === "game"),
  );
  elements.statsTab.setAttribute(
    "aria-selected",
    String(state.activeView === "stats"),
  );
  elements.statsTab.disabled = state.gameActive;
  elements.gameView.classList.toggle("active", state.activeView === "game");
  elements.statsView.classList.toggle("active", state.activeView === "stats");

  setAnimatedText(elements.levelValue, formatLevel(level));
  setAnimatedText(elements.storedLevelLabel, formatLevel(level));
  elements.levelDownButton.disabled = state.gameActive || state.levelIndex === 0;
  elements.levelUpButton.disabled =
    state.gameActive || state.levelIndex === LEVELS.length - 1;
  setAnimatedText(elements.startButton, isResetState() ? "Reset" : "Start");
  elements.startButton.classList.toggle("is-reset", isResetState());
  elements.clearProgressButton.disabled = state.gameActive;

  setAnimatedText(elements.phaseBadge, prettyPhase(state.phase));
  setAnimatedText(
    elements.resultBadge,
    state.lastOutcome === "correct"
      ? "OK"
      : state.lastOutcome === "wrong"
        ? "MISS"
        : "",
  );
  elements.resultBadge.classList.toggle(
    "correct",
    state.lastOutcome === "correct",
  );
  elements.resultBadge.classList.toggle("wrong", state.lastOutcome === "wrong");

  setAnimatedText(elements.roundCount, `${state.round} / ${TOTAL_ROUNDS}`);
  setAnimatedText(elements.correctCount, String(state.correct));
  setAnimatedText(elements.missedCount, String(state.missed));
  setAnimatedText(elements.accuracyCount, `${currentAccuracy}%`);
  elements.finishSummary.hidden = state.phase !== "finished";

  const visibleAnswer =
    state.currentAnswer === "" ? "\u00A0" : state.currentAnswer;
  setAnimatedText(elements.answerValue, visibleAnswer);
  elements.answerValue.classList.toggle("empty", state.currentAnswer === "");
  elements.clearButton.disabled =
    !state.acceptingAnswer || state.currentAnswer === "";
  elements.keypad.querySelectorAll(".key").forEach((button) => {
    button.disabled = !state.acceptingAnswer;
  });

  setAnimatedText(elements.lifetimeRuns, String(progressStats.totalRuns));
  setAnimatedText(
    elements.lifetimeAccuracy,
    `${progressStats.lifetimeAccuracy}%`,
  );
  setAnimatedText(elements.bestAccuracy, `${progressStats.bestAccuracy}%`);
  setAnimatedText(elements.bestStreak, String(progressStats.bestStreak));
  setAnimatedText(elements.recentCount, `${state.progress.runs.length} saved`);
  renderLevelMap(progressStats);
  renderHistory();
}

function isResetState() {
  return state.gameActive || state.phase === "finished";
}

function setAnimatedText(element, value) {
  if (element.textContent === value) {
    return;
  }

  element.textContent = value;
  pulseElement(element);
}

function pulseElement(element) {
  element.classList.remove("text-pop");
  void element.offsetWidth;
  element.classList.add("text-pop");
}

function buildProgressStats() {
  const runs = state.progress.runs;
  const totals = runs.reduce(
    (acc, run) => {
      acc.correct += run.correct;
      acc.rounds += run.rounds || run.correct + run.missed;
      acc.bestAccuracy = Math.max(acc.bestAccuracy, run.accuracy || 0);
      acc.bestStreak = Math.max(acc.bestStreak, run.bestStreak || 0);
      return acc;
    },
    {
      correct: 0,
      rounds: 0,
      bestAccuracy: 0,
      bestStreak: 0,
    },
  );

  return {
    totalRuns: runs.length,
    lifetimeAccuracy: calculateAccuracy(totals.correct, totals.rounds),
    bestAccuracy: totals.bestAccuracy,
    bestStreak: totals.bestStreak,
    levelRecords: buildLevelRecords(runs),
  };
}

function buildLevelRecords(runs) {
  return LEVELS.map((level) => {
    const levelRuns = runs.filter((run) => run.levelIndex === level.index);
    const bestRun = levelRuns.reduce(
      (best, run) => (!best || run.accuracy > best.accuracy ? run : best),
      null,
    );

    return {
      level,
      runs: levelRuns.length,
      bestAccuracy: bestRun ? bestRun.accuracy : 0,
      bestStreak: levelRuns.reduce(
        (best, run) => Math.max(best, run.bestStreak || 0),
        0,
      ),
    };
  });
}

function renderLevelMap(progressStats) {
  elements.levelMap.replaceChildren(
    ...progressStats.levelRecords.map((record) => {
      const item = document.createElement("button");
      item.type = "button";
      item.className = "level-cell";
      item.classList.toggle("current", record.level.index === state.levelIndex);
      item.classList.toggle("complete", record.bestAccuracy >= 80);
      item.disabled = state.gameActive;
      item.addEventListener("click", () => {
        state.levelIndex = record.level.index;
        applyLevelSettings();
        saveProgress();
        setView("game");
      });

      const name = document.createElement("span");
      name.className = "level-cell-name";
      name.textContent = formatShortLevel(record.level);

      const score = document.createElement("strong");
      score.textContent = `${record.bestAccuracy}%`;

      const meta = document.createElement("span");
      meta.textContent = `${record.runs} runs`;

      item.append(name, score, meta);
      return item;
    }),
  );
}

function renderHistory() {
  if (state.progress.runs.length === 0) {
    const empty = document.createElement("p");
    empty.className = "empty-state";
    empty.textContent = "No saved runs yet.";
    elements.historyList.replaceChildren(empty);
    return;
  }

  elements.historyList.replaceChildren(
    ...state.progress.runs.slice(0, 8).map((run) => {
      const item = document.createElement("article");
      item.className = "history-item";

      const main = document.createElement("div");
      const title = document.createElement("strong");
      title.textContent = run.levelLabel || formatLevel(LEVELS[run.levelIndex]);
      const date = document.createElement("span");
      date.textContent = formatDate(run.completedAt);
      main.append(title, date);

      const score = document.createElement("div");
      score.className = "history-score";
      score.textContent = `${run.accuracy || 0}%`;

      const detail = document.createElement("span");
      detail.textContent = `${run.correct}/${run.rounds || TOTAL_ROUNDS} correct`;
      score.append(detail);

      item.append(main, score);
      return item;
    }),
  );
}

function calculateAccuracy(correct, total) {
  return total ? Math.round((correct / total) * 100) : 0;
}

function formatLevel(level) {
  return `${level.speedLabel} ${level.nBack}-back`;
}

function formatShortLevel(level) {
  return `${level.speedLabel[0]}${level.nBack}`;
}

function formatDate(value) {
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return "Saved run";
  }

  return new Intl.DateTimeFormat(undefined, {
    month: "short",
    day: "numeric",
    hour: "numeric",
    minute: "2-digit",
  }).format(date);
}

function prettyPhase(phase) {
  switch (phase) {
    case "ready":
      return "Ready";
    case "memorize":
      return "Watch";
    case "answering":
      return "Answer";
    case "finished":
      return "Done";
    default:
      return "Idle";
  }
}

init();
