<Global.Microsoft.VisualBasic.CompilerServices.DesignerGenerated()> _
Partial Class DataSync
    Inherits System.Windows.Forms.Form

    'Form overrides dispose to clean up the component list.
    <System.Diagnostics.DebuggerNonUserCode()> _
    Protected Overrides Sub Dispose(ByVal disposing As Boolean)
        Try
            If disposing AndAlso components IsNot Nothing Then
                components.Dispose()
            End If
        Finally
            MyBase.Dispose(disposing)
        End Try
    End Sub

    'Required by the Windows Form Designer
    Private components As System.ComponentModel.IContainer

    'NOTE: The following procedure is required by the Windows Form Designer
    'It can be modified using the Windows Form Designer.  
    'Do not modify it using the code editor.
    <System.Diagnostics.DebuggerStepThrough()> _
    Private Sub InitializeComponent()
        Me.lbLog = New System.Windows.Forms.ListBox()
        Me.cmdRun = New System.Windows.Forms.Button()
        Me.pgProgress = New System.Windows.Forms.ProgressBar()
        Me.cmdAjuda = New System.Windows.Forms.Button()
        Me.cbREFER = New System.Windows.Forms.CheckBox()
        Me.cbREFERTelecom = New System.Windows.Forms.CheckBox()
        Me.cbREFERPatrimonio = New System.Windows.Forms.CheckBox()
        Me.cbREFEREngineering = New System.Windows.Forms.CheckBox()
        Me.SuspendLayout()
        '
        'lbLog
        '
        Me.lbLog.FormattingEnabled = True
        Me.lbLog.Location = New System.Drawing.Point(12, 12)
        Me.lbLog.Name = "lbLog"
        Me.lbLog.Size = New System.Drawing.Size(572, 316)
        Me.lbLog.TabIndex = 0
        '
        'cmdRun
        '
        Me.cmdRun.Location = New System.Drawing.Point(12, 361)
        Me.cmdRun.Name = "cmdRun"
        Me.cmdRun.Size = New System.Drawing.Size(57, 24)
        Me.cmdRun.TabIndex = 1
        Me.cmdRun.Text = "Executar"
        Me.cmdRun.UseVisualStyleBackColor = True
        '
        'pgProgress
        '
        Me.pgProgress.Location = New System.Drawing.Point(92, 361)
        Me.pgProgress.Name = "pgProgress"
        Me.pgProgress.Size = New System.Drawing.Size(492, 23)
        Me.pgProgress.TabIndex = 2
        '
        'cmdAjuda
        '
        Me.cmdAjuda.Location = New System.Drawing.Point(69, 361)
        Me.cmdAjuda.Name = "cmdAjuda"
        Me.cmdAjuda.Size = New System.Drawing.Size(21, 24)
        Me.cmdAjuda.TabIndex = 3
        Me.cmdAjuda.Text = "?"
        Me.cmdAjuda.UseVisualStyleBackColor = True
        '
        'cbREFER
        '
        Me.cbREFER.AutoSize = True
        Me.cbREFER.Checked = True
        Me.cbREFER.CheckState = System.Windows.Forms.CheckState.Checked
        Me.cbREFER.Location = New System.Drawing.Point(13, 338)
        Me.cbREFER.Name = "cbREFER"
        Me.cbREFER.Size = New System.Drawing.Size(62, 17)
        Me.cbREFER.TabIndex = 4
        Me.cbREFER.Text = "REFER"
        Me.cbREFER.UseVisualStyleBackColor = True
        '
        'cbREFERTelecom
        '
        Me.cbREFERTelecom.AutoSize = True
        Me.cbREFERTelecom.Checked = True
        Me.cbREFERTelecom.CheckState = System.Windows.Forms.CheckState.Checked
        Me.cbREFERTelecom.Location = New System.Drawing.Point(124, 338)
        Me.cbREFERTelecom.Name = "cbREFERTelecom"
        Me.cbREFERTelecom.Size = New System.Drawing.Size(106, 17)
        Me.cbREFERTelecom.TabIndex = 4
        Me.cbREFERTelecom.Text = "REFER Telecom"
        Me.cbREFERTelecom.UseVisualStyleBackColor = True
        '
        'cbREFERPatrimonio
        '
        Me.cbREFERPatrimonio.AutoSize = True
        Me.cbREFERPatrimonio.Checked = True
        Me.cbREFERPatrimonio.CheckState = System.Windows.Forms.CheckState.Checked
        Me.cbREFERPatrimonio.Location = New System.Drawing.Point(298, 338)
        Me.cbREFERPatrimonio.Name = "cbREFERPatrimonio"
        Me.cbREFERPatrimonio.Size = New System.Drawing.Size(114, 17)
        Me.cbREFERPatrimonio.TabIndex = 4
        Me.cbREFERPatrimonio.Text = "REFER Patrimonio"
        Me.cbREFERPatrimonio.UseVisualStyleBackColor = True
        '
        'cbREFEREngineering
        '
        Me.cbREFEREngineering.AutoSize = True
        Me.cbREFEREngineering.Checked = True
        Me.cbREFEREngineering.CheckState = System.Windows.Forms.CheckState.Checked
        Me.cbREFEREngineering.Location = New System.Drawing.Point(465, 338)
        Me.cbREFEREngineering.Name = "cbREFEREngineering"
        Me.cbREFEREngineering.Size = New System.Drawing.Size(121, 17)
        Me.cbREFEREngineering.TabIndex = 4
        Me.cbREFEREngineering.Text = "REFER Engineering"
        Me.cbREFEREngineering.UseVisualStyleBackColor = True
        '
        'DataSync
        '
        Me.AutoScaleDimensions = New System.Drawing.SizeF(6.0!, 13.0!)
        Me.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font
        Me.ClientSize = New System.Drawing.Size(598, 396)
        Me.Controls.Add(Me.cbREFEREngineering)
        Me.Controls.Add(Me.cbREFERPatrimonio)
        Me.Controls.Add(Me.cbREFERTelecom)
        Me.Controls.Add(Me.cbREFER)
        Me.Controls.Add(Me.cmdAjuda)
        Me.Controls.Add(Me.pgProgress)
        Me.Controls.Add(Me.cmdRun)
        Me.Controls.Add(Me.lbLog)
        Me.Name = "DataSync"
        Me.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen
        Me.Text = "Sincronização de utilizadores SICA"
        Me.ResumeLayout(False)
        Me.PerformLayout()

    End Sub
    Friend WithEvents lbLog As System.Windows.Forms.ListBox
    Friend WithEvents cmdRun As System.Windows.Forms.Button
    Friend WithEvents pgProgress As System.Windows.Forms.ProgressBar
    Friend WithEvents cmdAjuda As System.Windows.Forms.Button
    Friend WithEvents cbREFER As System.Windows.Forms.CheckBox
    Friend WithEvents cbREFERTelecom As System.Windows.Forms.CheckBox
    Friend WithEvents cbREFERPatrimonio As System.Windows.Forms.CheckBox
    Friend WithEvents cbREFEREngineering As System.Windows.Forms.CheckBox
End Class
