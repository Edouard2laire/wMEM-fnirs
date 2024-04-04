function pixel_size = getFigureSize(width_cm, height_cm)
% getFigureSize: Convert cm to pixel to create accuratly sized figure:
% Example:  Create a figure of 10 x 6 cm
% hFig = figure('Units','pixels','Position', getFigureSize(10, 6));
% plot(randn(10,1));
% set(hFig, 'PaperPositionMode', 'auto');
% saveas(hFig, 'test.svg');


    % Get screen size in pixels
    set(0, 'Units', 'pixels');
    screenPixels = get(0, 'ScreenSize'); % [left bottom width height]
    
    % Get screen size in centimeters
    set(0, 'Units', 'centimeters');
    screenCM = get(0, 'ScreenSize');
    
    % Compute horizontal and vertical DPI
    dpiX = screenPixels(3) / screenCM(3) ;
    dpiY = screenPixels(4) / screenCM(4) ;
    
    % Compute dpi
    dpi = mean([dpiX, dpiY]);
    
    % define some constant so it's working
    evil_const =  1.3355;

    % Convert cm to pixel.
    width_px    = round(width_cm * dpi * evil_const);
    height_px   = round(height_cm * dpi * evil_const);
    
    % generate figure output size
    pixel_size = [0 0 width_px height_px];
end