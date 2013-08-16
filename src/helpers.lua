function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

function initializeGrid(rows, cols)
  local tmp = {}
  for i=1,rows do
    tmp[i] = {}
    for j=1,cols do
      tmp[i][j] = 0
    end
  end

  return tmp
end

function rprint(table)
  for k,v in ipairs(table) do
    if type(v) == 'table' then
      rprint(v)
    end

    print(v)
  end
end
