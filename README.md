# N-Back Math

Mobile-first arithmetic `n-back` trainer. Static frontend only.

![N-Back Math screenshot](assets/screenshot.png)

## Use

Open `index.html` directly, or serve the folder:

```sh
python3 -m http.server 8003
```

Then open `http://localhost:8003`.

## Play

- Use `-` and `+` to change level.
- Press `Start`.
- Answer the problem from `N` steps back.
- Each run is always `24` questions.
- `Slow` gives `4s`; `Fast` gives `3s`.
- Use `Stats` to review saved browser progress.

Progress is stored in browser `localStorage`. Use `Clear Progress` on the
stats page to reset it.
