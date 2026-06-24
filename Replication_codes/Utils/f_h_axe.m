function f_h_axe(AxisFontName,AxisFontSize,AxisBoxRatio)
h_axes = gca;
if nargin == 3
    h_axes.PlotBoxAspectRatio = AxisBoxRatio;
end
h_axes.XAxis.FontName = AxisFontName;  h_axes.YAxis.FontName = AxisFontName;
h_axes.XAxis.FontSize = AxisFontSize;  h_axes.YAxis.FontSize = AxisFontSize;
box off