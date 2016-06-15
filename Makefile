build: elm.js

elm.js: Main.elm
	elm make Main.elm --yes --output elm.js
