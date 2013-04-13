
module ('mapgenerator', package.seeall) do

  function pertile(table, fun)
    for j,row in ipairs(table) do
      for i,tile in ipairs(row) do
        fun(tile, j, i)
      end
    end 
  end
  function matrix_get(table, j, i)
    return table[j] and table[j][i]
  end
  function array_remove_if(array, fun)
    local result = {}
    for _,v in ipairs(array) do
      if not fun(v) then table.insert(result, v) end
    end
    return result
  end
  function create_matrix(height, width, fun)
    local matrix = {}
    for j=1,height do
      matrix[j] = {}
      if fun then
        for i=1,width do
          matrix[j][i] = fun(j,i)
        end
      end
    end
    return matrix
  end

end