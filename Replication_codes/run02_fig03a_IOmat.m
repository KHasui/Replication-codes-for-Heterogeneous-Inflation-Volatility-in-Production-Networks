clc
close all
clear
% Description
% This code plots Figure 3(a).
% Code author: Kohei Hasui (Aichi University)

% Preparation

Save_fig = 1;
figformat = 'svg';
plot_xylabel = 1;

% Loading deep param val (ALFA)
load Database_model ALPHA_

% Font size
FS_title   = 17;
FS_xlabel  = 16;
FS_ylabel  = FS_xlabel;
FS_textbox = 15;
FS_axe     = 12;
FS_legend  = 18;
FName      = 'Arial';



% Histgram

FaceColor5 = [0.45,0.65,0.9];
% FaceColor5 = [0.6,0.6,0.6];

% Line 
LS = 'n';


load Database_model GG fc Igg OMGs GAMs
V    = ALPHA_*(  ( (Igg - (1-ALPHA_)*GG) )\fc  );


% Fig number
ind_fig = 1;


% for heatmap
[maxx,maxy] = size(GG);

intx = 10;
inty = intx;
xgrid = 1:maxx;
ygrid = 1:maxy;

string_xgrid = string(xgrid);
string_ygrid = string(ygrid);

string_xgrid(mod(xgrid,intx) ~= 0) = " ";
string_ygrid(mod(ygrid,intx) ~= 0) = " ";



FigPosition4 = [550 400 600 500];

%% FIG 2: Scatters and Heatmap plot for IO matrix G

ns = size(GG,1);


f=figure(ind_fig);
f.Position = FigPosition4;

[x, y]= meshgrid(1:ns,ns:-1:1);
bubblechart(x(:),y(:),GG(:),'MarkerFaceAlpha',1,'MarkerEdgeColor','n','MarkerFaceColor',FaceColor5 )
bubblesize([1 15])% bubblesize
set(gca,'FontSize',FS_axe,'FontName',FName)
upperxticks = round(ns,-1)-10;
loweryticks = ns-upperxticks+1;
xticks([1,10:10:upperxticks])
yticks([loweryticks:10:(ns-10+1),ns])
yticklabels([upperxticks:-10:10,1])

xlim([0 ns+1])
ylim([0 ns+1])

if plot_xylabel==1
    title('(a)','FontSize',FS_title,'FontName',FName)
    xlabel('Input-using sector','FontSize',FS_xlabel,'FontName',FName)
    ylabel('Input-supplying sector','FontSize',FS_ylabel,'FontName',FName)
end

% box off

if Save_fig == 1
    figname = 'fig03';
    saveas(f,figname,figformat)
end
