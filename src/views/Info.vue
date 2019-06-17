<template>

  <div class="info">
    <div class="modal-header">
        <a id="modalCloseTop" class="btn btn-clear float-right" aria-label="Close"></a>
        <div class="modal-title h5">Beethovens Werkstatt <small>Modul 2</small></div>
        <div id="versionInfo" class="text-gray"><small>Version <a class="text-gray" href="$$git-url$$" target="_blank">$$git-short$$</a><span class="dirty-$$git-dirty$$">, with uncommited changes</span></small></div>
    </div>
    <div class="modal-body">
        <div class="content">
            Dieser Prototyp ist noch in Arbeit und kann sich jederzeit ändern. Wenn Sie Feedback melden möchten, stellen Sie bitte sicher, dass Sie die Information zum
            git commit hash ($$git-short$$) angeben.<br/>
            Der Zweck dieses Prototyps ist es, Konzepte für das zweite Modul unseres Projekts zu erproben, das sich mit Beethoven als Bearbeiter eigener Werke beschäftigt.
            Während wir in unserem ersten Modul versucht haben, genetische Prozesse in Manuskripten nachzuvollziehen, versuchen wir nun, solche Spuren in gedruckten Texten
            zu finden: Wie hat Beethoven seine Werke für andere Besetzungen arrangiert? Inwieweit hält er sich an die Vorlage? Diese und andere Fragen werden durch den
            Vergleich der musikalischen Texte von Vorlagen und Arrangements untersucht.
            <br/>
            Was Sie hier sehen, ist ein ungeschützter Blick in unsere Werkstatt. Weder die Daten oder die Software noch die Konzepte, die darin umgesetzt werden, entsprechen
            unseren Zielvorstellungen für eine Umsetzung in diesem Modul. Es ist nur ein Aspekt, den wir gerne ausprobieren würden. Natürlich freuen wir uns über <a href="mailto:info@beethovens-werkstatt.de">Feedback</a>,
            mit dem wir unterschiedliche Ansätze evaluieren können.
        </div>
    </div>
    <div class="modal-footer">
        <button id="modalCloseBottom" class="btn btn-primary">schließen</button>
    </div>
  </div>
</template>

<script>
// @ is an alias to /src

export default {
  name: 'Info',
  components: {

  }
}
</script>
