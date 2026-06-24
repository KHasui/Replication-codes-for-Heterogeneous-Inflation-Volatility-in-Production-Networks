function xylabel(xystring,xyFontSize,xyFontName,Weight,flagLatex,flagrotation)

if nargin < 6, flagrotation= 0; end
if nargin < 5, flagLatex= 0; end
if nargin < 4, Weight=1; flagLatex= 0; end
if isempty(Weight), Weight = 1; end
if isempty(flagLatex), flagLatex= 0; end

if flagrotation==1
    if flagLatex==1
        xlabel(xystring{1},'Interpreter','Latex', 'FontSize',Weight*xyFontSize(1))
        ylabel(xystring{2},'Interpreter','Latex', 'FontSize',Weight*xyFontSize(2),"Rotation",0)
    elseif flagLatex==2
        xlabel(xystring{1},'FontName', xyFontName{1}, 'FontSize',Weight*xyFontSize(1))
        ylabel(xystring{2},'Interpreter','Latex', 'FontSize',Weight*xyFontSize(2),"Rotation",0)
    elseif flagLatex==3
        xlabel(xystring{1},'Interpreter','Latex', 'FontSize',Weight*xyFontSize(1))
        ylabel(xystring{2},'FontName', xyFontName{2}, 'FontSize',Weight*xyFontSize(2),"Rotation",0)
    else
        xlabel(xystring{1},'FontName', xyFontName{1}, 'FontSize',Weight*xyFontSize(1))
        ylabel(xystring{2},'FontName', xyFontName{2}, 'FontSize',Weight*xyFontSize(2),"Rotation",0)
    end
else
    if flagLatex==1
        xlabel(xystring{1},'Interpreter','Latex', 'FontSize',Weight*xyFontSize(1))
        ylabel(xystring{2},'Interpreter','Latex', 'FontSize',Weight*xyFontSize(2))
    elseif flagLatex==2
        xlabel(xystring{1},'FontName', xyFontName{1}, 'FontSize',Weight*xyFontSize(1))
        ylabel(xystring{2},'Interpreter','Latex', 'FontSize',Weight*xyFontSize(2))
    elseif flagLatex==3
        xlabel(xystring{1},'Interpreter','Latex', 'FontSize',Weight*xyFontSize(1))
        ylabel(xystring{2},'FontName', xyFontName{2}, 'FontSize',Weight*xyFontSize(2))
    else
        xlabel(xystring{1},'FontName', xyFontName{1}, 'FontSize',Weight*xyFontSize(1))
        ylabel(xystring{2},'FontName', xyFontName{2}, 'FontSize',Weight*xyFontSize(2))
    end
end

