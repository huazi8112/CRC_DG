function outpng(figureHandle, figureWidth, figureHeight, fileout)
    set(findall(figureHandle,'-property','FontSize'),'FontSize',14);
    set(findall(figureHandle,'-property','FontName'),'FontName','Arial');
    set(figureHandle,'PaperUnits','centimeters');
    set(figureHandle,'PaperPosition',[0 0 figureWidth figureHeight]);
    print(figureHandle,[fileout,'.png'],'-r600','-dpng');
end
