% Version : 5.3
% Date : 12.01.2010
% Author  : Omid Bonakdar Sakhi

function output = mminmax(input)

max_ = max(max(input));
min_ = min(min(input));

output = ((input-min_)/(max_-min_) - 0.5) * 2;