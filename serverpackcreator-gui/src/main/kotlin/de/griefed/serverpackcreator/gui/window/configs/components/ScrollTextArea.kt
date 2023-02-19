package de.griefed.serverpackcreator.gui.window.configs.components

import java.io.File
import java.util.*
import javax.swing.JScrollPane
import javax.swing.JTextArea
import javax.swing.event.DocumentListener

/**
 * TODO docs
 */
class ScrollTextArea(
    text: String,
    private val textArea: JTextArea = JTextArea(text),
    verticalScrollbarVisibility: Int = VERTICAL_SCROLLBAR_AS_NEEDED,
    horizontalScrollbarVisibility: Int = HORIZONTAL_SCROLLBAR_NEVER
) : JScrollPane(verticalScrollbarVisibility, horizontalScrollbarVisibility) {

    constructor(text: String, documentChangeListener: DocumentChangeListener) : this(text) {
        addDocumentListener(documentChangeListener)
    }
    constructor(text: List<String>) : this(text.joinToString(","))
    constructor(text: List<String>, documentChangeListener: DocumentChangeListener) : this(text.joinToString(",")) {
        addDocumentListener(documentChangeListener)
    }
    constructor(text: TreeSet<String>) : this(text.joinToString(","))
    constructor(text: TreeSet<String>, documentChangeListener: DocumentChangeListener) : this(text.joinToString(",")) {
        addDocumentListener(documentChangeListener)
    }

    init {
        textArea.lineWrap = true
        viewport.view = textArea
    }

    var text: String
        get() {
            return textArea.text
        }
        set(value) {
            textArea.text = value
        }

    /**
     * TODO docs
     */
    fun addDocumentListener(listener: DocumentListener) {
        textArea.document.addDocumentListener(listener)
    }
}