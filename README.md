# Systemocracy

A card game where you choose a System, build a deck, and create a structure of Place, Force, and Event cards.

Cards can be Occult, Corporate, Military, or Neutral.
There are also minor types like Income, Naval, or Revolutionary.

The rules are in another castle.

[View the cards online][Website] (Warning: placeholder art uses unnecessarily high-resolution images!)

The first thing prototyped with [Card Game Generator][].


## Import into [Tabletop Simulator][]

Without installing, you can save [`Systemocracy.json`][] to `%USERPROFILE%\Documents\My Games\Tabletop Simulator\Saves\Chest\`

If installed, you can just `npm run export-to-tabletop-simulator`

Then in Tabletop Simulator, go to **Host > Chest > Saved Objects** and find **Systemocracy**.


## Installation

* [Clone the repo][Cloning a repository]
* Install [Node.js][] if you don't have a somewhat recent version
* Open a console in the project directory
* Run `npm install`


## Update cards

* `npm run import` following the steps the first time *with a Google account that has access to the Google Docs*
* `npm run export`
* `npm run export-to-tabletop-simulator`

You can `set PARALLEL_EXPORT=ON` before running `export` to speed it up significantly if it's on a powerful enough machine,
but if it's not powerful enough it might freeze up the entire computer.

The credentials for importing may eventually expire, in which case they must be deleted manually before importing again.
(`rm %USERPROFILE%\.credentials\nodejs-drive-access.json`)


[Website]: http://1j01.github.io/systemocracy/
[`Systemocracy.json`]: https://raw.githubusercontent.com/1j01/systemocracy/gh-pages/data/export/Systemocracy.json
[Node.js]: https://nodejs.org/en/
[Tabletop Simulator]: http://store.steampowered.com/app/286160/
[Card Game Generator]: https://github.com/1j01/card-game-generator
[Cloning a repository]: https://help.github.com/articles/cloning-a-repository/
