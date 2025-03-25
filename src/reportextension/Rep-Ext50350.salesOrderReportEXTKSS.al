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
        addafter(Line)
        {
            dataitem(salesHeader; "Sales Header")
            {
                dataitem(salesLine; "Sales Line")
                {
                    UseTemporary = true;
                    DataItemLink = "Document No." = field("No."), "Document Type" = field("Document Type");
                    column(Item_No_KSS; "No.") { }
                    column(Description_KSS; Description) { }
                    column(Quantity_KSS; Quantity) { }
                    column(Unit_of_Measure_KSS; "Unit of Measure") { }
                    column(Unit_Price_KSS; "Unit Price") { }
                    column(VAT_KSS; "VAT %") { }
                    column(Line_Amount_KSS; "Line Amount") { }

                    trigger OnPreDataItem()
                    var
                        isFound: Boolean;
                        tempSalesLine: Record "Sales Line";
                    begin
                        Clear(salesLine);
                        tempSalesLine.SetRange("Document No.", salesHeader."No.");

                        if tempSalesLine.FindSet() then
                            repeat
                                isFound := false;
                                if salesLine.FindFirst() then
                                    repeat
                                        if tempSalesLine."No." = salesLine."No." then begin
                                            salesLine.Quantity += tempSalesLine.Quantity;
                                            salesLine."Line Amount" += tempSalesLine."Line Amount";
                                            salesLine.Modify();
                                            isFound := true;
                                        end;
                                    until salesLine.Next() = 0;
                                if not isFound then begin
                                    salesLine := tempSalesLine;
                                    salesLine.Insert();
                                end;

                            until tempSalesLine.Next() = 0;
                    end;
                }
                trigger OnPreDataItem()
                var
                    myInt: Integer;
                begin
                    if orderNo <> '' then begin
                        salesHeader.SetRange("No.", orderNo);
                    end
                    else
                        Error('Give Sales Order Number Please');
                end;
            }
        }
    }

    requestpage
    {
        // Add changes to the requestpage here
        layout
        {
            addafter(Options)
            {
                group(sales_order_kss)
                {
                    field(orderNo; orderNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Give Sales Order No.';
                        TableRelation = "Sales Header"."No." where("Document Type" = const(Order));
                    }
                }
            }
        }

    }

    var
        orderNo: Code[30];
        totalTax: Decimal;
        currTaxAmount: Decimal;
}