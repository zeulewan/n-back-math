const elements = {
  resultBadge: document.getElementById("result-badge"),
  phaseBadge: document.getElementById("phase-badge"),
  problemDisplay: document.getElementById("problem-display"),
  timerFill: document.getElementById("timer-fill"),
  answerValue: document.getElementById("answer-value"),
  clearButton: document.getElementById("clear-btn"),
  roundCount: document.getElementById("round-count"),
  questionCount: document.getElementById("question-count"),
  correctCount: document.getElementById("correct-count"),
  missedCount: document.getElementById("missed-count"),
  accuracyCount: document.getElementById("accuracy-count"),
  streakCount: document.getElementById("streak-count"),
  resultsPhase: document.getElementById("results-phase"),
  keypad: document.getElementById("keypad"),
  startButton: document.getElementById("start-btn"),
  resetButton: document.getElementById("reset-btn"),
  settingsButton: document.getElementById("settings-btn"),
  closeSettingsButton: document.getElementById("close-settings-btn"),
  settingsSheet: document.getElementById("settings-sheet"),
  settingsScrim: document.getElementById("settings-scrim"),
  nLevel: document.getElementById("n-level"),
  rounds: document.getElementById("rounds"),
  answerMs: document.getElementById("answer-ms"),
};

const KEY_LAYOUT = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"];

const state = {
  gameActive: false,
  acceptingAnswer: false,
  settingsOpen: false,
  phase: "idle",
  nBack: 1,
  totalRounds: 15,
  answerMs: 3000,
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
  lastOutcome: null,
  timers: [],
  timerAnimation: null,
};

function init() {
  buildKeypad();
  bindEvents();
  syncSettingsFromControls();
  render();
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
  elements.startButton.addEventListener("click", startGame);
  elements.resetButton.addEventListener("click", resetGame);
  elements.clearButton.addEventListener("click", clearAnswer);
  elements.settingsButton.addEventListener("click", toggleSettings);
  elements.closeSettingsButton.addEventListener("click", closeSettings);
  elements.settingsScrim.addEventListener("click", closeSettings);

  [elements.nLevel, elements.rounds, elements.answerMs].forEach((control) => {
    control.addEventListener("change", () => {
      syncSettingsFromControls();
      render();
    });
  });

  window.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && state.settingsOpen) {
      closeSettings();
      return;
    }

    if (!state.acceptingAnswer) {
      return;
    }

    if (/^[0-9]$/.test(event.key)) {
      appendDigit(event.key);
      return;
    }

    if (event.key === "Backspace") {
      clearAnswer();
      return;
    }
  });
}

function toggleSettings() {
  state.settingsOpen = !state.settingsOpen;
  render();
}

function closeSettings() {
  state.settingsOpen = false;
  render();
}

function syncSettingsFromControls() {
  state.nBack = Number(elements.nLevel.value);
  state.totalRounds = Number(elements.rounds.value);
  state.answerMs = Number(elements.answerMs.value);
}

function startGame() {
  clearAllTimers();
  stopTimerBar();
  state.settingsOpen = false;
  syncSettingsFromControls();

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
  state.lastOutcome = null;

  setProblem("Ready");
  render();

  queue(nextRound, 700);
}

function resetGame() {
  clearAllTimers();
  state.gameActive = false;
  stopTimerBar();
  state.acceptingAnswer = false;
  state.settingsOpen = false;
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
  state.lastOutcome = null;

  setProblem("-");
  render();
}

function nextRound() {
  if (state.answeredQuestions >= state.totalRounds) {
    finishGame();
    return;
  }

  state.displayStep += 1;
  state.currentAnswer = "";
  state.currentProblem = buildProblem();
  state.problems.push(state.currentProblem);
  state.currentTarget = null;

  const visibleProblem = formatProblem(state.currentProblem);
  setProblem(visibleProblem, true);
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
  setProblem("✓");
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
  const accuracy = state.answeredQuestions
    ? Math.round((state.correct / state.answeredQuestions) * 100)
    : 0;

  document.body.classList.toggle("playing", state.gameActive);
  elements.phaseBadge.textContent = prettyPhase(state.phase);
  elements.resultBadge.textContent =
    state.lastOutcome === "correct"
      ? "✓"
      : state.lastOutcome === "wrong"
        ? "✕"
        : "";
  elements.resultBadge.classList.toggle(
    "correct",
    state.lastOutcome === "correct",
  );
  elements.resultBadge.classList.toggle("wrong", state.lastOutcome === "wrong");
  elements.roundCount.textContent = `${state.round} / ${state.totalRounds}`;
  elements.questionCount.textContent = String(state.answeredQuestions);
  elements.correctCount.textContent = String(state.correct);
  elements.missedCount.textContent = String(state.missed);
  elements.accuracyCount.textContent = `${accuracy}%`;
  elements.streakCount.textContent = String(state.streak);
  elements.resultsPhase.textContent = prettyPhase(state.phase);

  const visibleAnswer =
    state.currentAnswer === "" ? "\u00A0" : state.currentAnswer;
  elements.answerValue.textContent = visibleAnswer;
  elements.answerValue.classList.toggle("empty", state.currentAnswer === "");

  [elements.nLevel, elements.rounds, elements.answerMs].forEach((control) => {
    control.disabled = state.gameActive;
  });

  elements.startButton.disabled = state.gameActive;
  elements.settingsButton.setAttribute(
    "aria-expanded",
    String(state.settingsOpen),
  );
  elements.settingsSheet.hidden = !state.settingsOpen;
  elements.settingsScrim.hidden = !state.settingsOpen;

  elements.keypad.querySelectorAll(".key").forEach((button) => {
    button.disabled = !state.acceptingAnswer;
  });
  elements.clearButton.disabled =
    !state.acceptingAnswer || state.currentAnswer === "";
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
