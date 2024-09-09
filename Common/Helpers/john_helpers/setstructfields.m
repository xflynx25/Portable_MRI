% given specifications (often plotting) unpacking helper
function s = setstructfields(defaults, userOptions)
    fields = fieldnames(userOptions);
    for i = 1:length(fields)
        defaults.(fields{i}) = userOptions.(fields{i});
    end
    s = defaults;
end