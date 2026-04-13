function path = get_cache_path(name)
    % Get the path to the cache directory
    if ~exist('./cache', 'dir')
        mkdir('./cache')
    end

    path = strcat('./cache/', name, '.mat');
end
