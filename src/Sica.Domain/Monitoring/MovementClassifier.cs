using System.Globalization;

namespace Sica.Domain.Monitoring;

/// <summary>
/// RULE-011: classifies an access movement as Entry, Exit or Unknown.
/// <para>
/// The circuit description takes priority: if it contains an entry/exit token
/// (ENTRADA / SALIDA / SAÍDA), that determines the type even when the numeric
/// parameter contradicts it. Otherwise the numeric parameter is used
/// (1 = Entry, 2 = Exit). Anything else is Unknown.
/// </para>
/// </summary>
public static class MovementClassifier
{
    private const int EntryParameter = 1;
    private const int ExitParameter = 2;

    public static AccessEventType Classify(string? description, int parameter)
    {
        var fromDescription = ClassifyByDescription(description);
        if (fromDescription != AccessEventType.Unknown)
        {
            return fromDescription;
        }

        return parameter switch
        {
            EntryParameter => AccessEventType.Entry,
            ExitParameter => AccessEventType.Exit,
            _ => AccessEventType.Unknown,
        };
    }

    private static AccessEventType ClassifyByDescription(string? description)
    {
        if (string.IsNullOrWhiteSpace(description))
        {
            return AccessEventType.Unknown;
        }

        var normalized = RemoveDiacritics(description.ToUpperInvariant());

        if (normalized.Contains("ENTRADA", StringComparison.Ordinal))
        {
            return AccessEventType.Entry;
        }

        if (normalized.Contains("SALIDA", StringComparison.Ordinal)
            || normalized.Contains("SAIDA", StringComparison.Ordinal))
        {
            return AccessEventType.Exit;
        }

        return AccessEventType.Unknown;
    }

    private static string RemoveDiacritics(string text)
    {
        var normalized = text.Normalize(System.Text.NormalizationForm.FormD);
        var builder = new System.Text.StringBuilder(normalized.Length);

        foreach (var ch in normalized)
        {
            if (CharUnicodeInfo.GetUnicodeCategory(ch) != UnicodeCategory.NonSpacingMark)
            {
                builder.Append(ch);
            }
        }

        return builder.ToString().Normalize(System.Text.NormalizationForm.FormC);
    }
}
