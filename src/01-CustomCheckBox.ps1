Add-Type -ReferencedAssemblies @('System.Windows.Forms', 'System.Drawing') -TypeDefinition @'
using System;
using System.Drawing;
using System.Windows.Forms;

public class SimpleOriginCheckBox : CheckBox
{
    public Color BoxBorderColor { get; set; }
    public Color BoxBackColor { get; set; }
    public Color CheckMarkColor { get; set; }
    public Color HoverBorderColor { get; set; }
    public Color DisabledBorderColor { get; set; }
    public Color DisabledCheckMarkColor { get; set; }
    public int BoxSize { get; set; }

    private bool _hovered;

    public SimpleOriginCheckBox()
    {
        SetStyle(
            ControlStyles.AllPaintingInWmPaint |
            ControlStyles.OptimizedDoubleBuffer |
            ControlStyles.ResizeRedraw |
            ControlStyles.UserPaint |
            ControlStyles.SupportsTransparentBackColor,
            true
        );

        AutoSize = false;
        UseVisualStyleBackColor = false;

        BoxBorderColor = Color.FromArgb(200, 205, 214);
        BoxBackColor = Color.White;
        CheckMarkColor = Color.FromArgb(53, 107, 187);
        HoverBorderColor = Color.FromArgb(90, 120, 170);
        DisabledBorderColor = Color.FromArgb(180, 180, 180);
        DisabledCheckMarkColor = Color.FromArgb(150, 150, 150);
        BoxSize = 16;
    }

    protected override void OnMouseEnter(EventArgs e)
    {
        _hovered = true;
        Invalidate();
        base.OnMouseEnter(e);
    }

    protected override void OnMouseLeave(EventArgs e)
    {
        _hovered = false;
        Invalidate();
        base.OnMouseLeave(e);
    }

    protected override void OnCheckedChanged(EventArgs e)
    {
        Invalidate();
        base.OnCheckedChanged(e);
    }

    protected override void OnEnabledChanged(EventArgs e)
    {
        Invalidate();
        base.OnEnabledChanged(e);
    }

    protected override void OnTextChanged(EventArgs e)
    {
        Invalidate();
        base.OnTextChanged(e);
    }

    protected override void OnBackColorChanged(EventArgs e)
    {
        Invalidate();
        base.OnBackColorChanged(e);
    }

    protected override void OnForeColorChanged(EventArgs e)
    {
        Invalidate();
        base.OnForeColorChanged(e);
    }

    protected override void OnFontChanged(EventArgs e)
    {
        Invalidate();
        base.OnFontChanged(e);
    }

    protected override void OnPaint(PaintEventArgs e)
    {
        Color surfaceColor = Parent != null ? Parent.BackColor : BackColor;
        using (SolidBrush surfaceBrush = new SolidBrush(surfaceColor))
        {
            e.Graphics.FillRectangle(surfaceBrush, ClientRectangle);
        }

        e.Graphics.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.AntiAlias;

        int boxTop = Math.Max(0, (Height - BoxSize) / 2);
        Rectangle boxRect = new Rectangle(0, boxTop, BoxSize, BoxSize);

        Color borderColor = Enabled
            ? (_hovered ? HoverBorderColor : BoxBorderColor)
            : DisabledBorderColor;

        using (SolidBrush fillBrush = new SolidBrush(BoxBackColor))
        {
            e.Graphics.FillRectangle(fillBrush, boxRect);
        }

        using (Pen borderPen = new Pen(borderColor, 1.4f))
        {
            e.Graphics.DrawRectangle(borderPen, boxRect);
        }

        if (Checked)
        {
            using (Pen checkPen = new Pen(Enabled ? CheckMarkColor : DisabledCheckMarkColor, 2.2f))
            {
                checkPen.StartCap = System.Drawing.Drawing2D.LineCap.Round;
                checkPen.EndCap = System.Drawing.Drawing2D.LineCap.Round;

                Point p1 = new Point(boxRect.Left + 3, boxRect.Top + (BoxSize / 2));
                Point p2 = new Point(boxRect.Left + 7, boxRect.Bottom - 4);
                Point p3 = new Point(boxRect.Right - 3, boxRect.Top + 4);

                e.Graphics.DrawLines(checkPen, new[] { p1, p2, p3 });
            }
        }

        Rectangle textRect = new Rectangle(boxRect.Right + 10, 0, Math.Max(0, Width - (boxRect.Right + 10)), Height);
        TextFormatFlags flags = TextFormatFlags.Left | TextFormatFlags.VerticalCenter | TextFormatFlags.EndEllipsis | TextFormatFlags.NoPrefix;
        Color textColor = Enabled ? ForeColor : SystemColors.GrayText;

        TextRenderer.DrawText(e.Graphics, Text ?? string.Empty, Font, textRect, textColor, flags);

        if (Focused && ShowFocusCues)
        {
            Size measured = TextRenderer.MeasureText(Text ?? string.Empty, Font);
            Rectangle focusRect = new Rectangle(textRect.Left, Math.Max(0, textRect.Top + 4), Math.Min(textRect.Width, measured.Width + 4), Math.Max(12, Height - 8));
            ControlPaint.DrawFocusRectangle(e.Graphics, focusRect);
        }
    }
}
'@

