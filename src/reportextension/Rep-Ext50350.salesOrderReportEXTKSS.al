reportextension 50350 "salesOrderReportEXT_KSS" extends "Standard Sales - Order Conf."
{
    RDLCLayout = './salesOrderReportEXT_KSS.rdl';

    dataset
    {
        // Add changes to dataitems and columns here
        add(Line)
        {
            column(Line_Discount_Amount; "Line Discount Amount") { }
            column(totalTax; totalTax) { }
        }
        modify(Line)
        {
            trigger OnAfterAfterGetRecord()
            var
                newLine: Record "Sales Line";
            begin
                totalTax := 0;
                newLine.SetRange("Document No.", Line."Document No.");
                if newLine.FindSet() then
                    repeat
                        currTaxAmount := newLine."Amount Including VAT" - newLine."Line Amount";
                        totalTax += currTaxAmount;
                    until newLine.Next() = 0;
            end;
        }
    }

    requestpage
    {
        // Add changes to the requestpage here
    }
    var
        totalTax: Decimal;
        currTaxAmount: Decimal;
}