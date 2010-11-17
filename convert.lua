#! /usr/bin/lua

local function quote(s)
    local q = '';
    while s:find(']' .. q .. ']', 1, true) do
        q = q .. '=';
    end;
    return string.format('[%s[%s]%s]', q, s, q);
end;

local bool_setting = {
    background = true, disable_auto_reload = true, double_buffer = true, draw_borders = true,
    draw_graph_borders = true, draw_outline = true, draw_shades = true, extra_newline = true,
    format_human_readable = true, no_buffers = true, out_to_console = true,
    out_to_ncurses = true, out_to_stderr = true, out_to_x = true, override_utf8_locale = true,
    own_window = true, own_window_argb_visual = true, own_window_transparent = true,
    short_units = true, show_graph_range = true, show_graph_scale = true,
    times_in_seconds = true, top_cpu_separate = true, uppercase = true, use_xft = true
};

local num_setting = {
    border_inner_margin = true, border_outer_margin = true, border_width = true,
    cpu_avg_samples = true, diskio_avg_samples = true, gap_x = true, gap_y = true,
    imlib_cache_flush_interval = true, imlib_cache_size = true,
    max_port_monitor_connections = true, max_text_width = true, max_user_text = true,
    maximum_width = true, mpd_port = true, music_player_interval = true, net_avg_samples = true,
    own_window_argb_value = true, pad_percents = true, stippled_borders = true,
    text_buffer_size = true, top_name_width = true, total_run_times = true,
    update_interval = true, update_interval_on_battery = true, xftalpha = true
};

local split_setting = {
    default_bar_size = true, default_gauge_size = true, default_graph_size = true,
    minimum_size = true
};

local colour_setting = {
    color0 = true, color1 = true, color2 = true, color3 = true, color4 = true, color5 = true,
    color6 = true, color7 = true, color8 = true, color9 = true, default_color = true,
    default_outline_color = true, default_shade_color = true, own_window_colour = true
};

local function alignment_map(value)
    local map = { m = 'middle', t = 'top', b = 'bottom', r = 'right', l = 'left' };
    if map[value] == nil then
        return value;
    else
        return map[value];
    end;
end;

local function handle(setting, value)
    setting = setting:lower();
    if setting == '' then
        return '';
    end;
    if split_setting[setting] then
        local x, y = value:match('^(%S+)%s*(%S*)$');
        local ret = setting:gsub('_size', '_width = ') .. x .. ',';
        if y ~= '' then
            ret = ret .. ' ' .. setting:gsub('_size', '_height = ') .. y .. ',';
        end;
        return '\t' .. ret;
    end;
    if bool_setting[setting] then
        value = value:lower();
        if value == 'yes' or value == 'true' or value == '1' then
            value = 'true';
        else
            value = 'false';
        end;
    elseif not num_setting[setting] then
        if setting == 'alignment' and value:len() == 2 then
            value = alignment_map(value:sub(1,1)) .. '_' .. alignment_map(value:sub(2,2));
        end;
        if colour_setting[setting] and value:match('^[0-9a-fA-F]+$') then
            value = '#' .. value;
        end;
        value = quote(value);
    end;
    return '\t' .. setting .. ' = ' .. value .. ',';
end;

local function convert(s)
    local setting, comment = s:match('^([^#]*)#?(.*)\n$');
    if comment ~= '' then
        comment = '--' .. comment;
    end;
    comment = comment .. '\n';
    return handle(setting:match('^%s*(%S*)%s*(.-)%s*$')) ..  comment;
end;

local input = io.input();
local output = io.output();

local config = input:read('*a');

local settings, text = config:match('^(.-)TEXT\n(.*)$');

output:write('conky.config = {\n', settings:gsub('.-\n', convert), '};\n\n');
output:write('conky.text = ', quote(text), ';\n');