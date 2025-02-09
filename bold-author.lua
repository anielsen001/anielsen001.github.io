-- https://stackoverflow.com/questions/76394078/format-specific-authors-with-bold-font-in-bibliography-created-with-quarto

str = pandoc.utils.stringify

local function highlight_author_filter(auths)
  return {
    Para = function(el)
      if el.t == "Para" then
        for k,_ in ipairs(el.content) do
          for key, val in ipairs(auths) do
            local first_part = val.family .. ","
            local second_part = "^" .. val.given
            local full = val.family .. ", " .. val.given
            if el.content[k].t == "Str" and el.content[k].text == first_part
            and el.content[k+1].t == "Space"
            and el.content[k+2].t == "Str" and el.content[k+2].text:find(second_part) then
                local _,e = el.content[k+2].text:find(second_part)
                local rest = el.content[k+2].text:sub(e+1) 
                el.content[k] = pandoc.Strong { pandoc.Str(full) }
                el.content[k+1] = pandoc.Str(rest)
                table.remove(el.content, k+2)
            end
          end
        end
      end
    return el
    end
  }
end


local function get_auth_name(auths)
  return {
    Meta = function(m)
      for key, val in ipairs(m['bold-auth-name']) do
        local auth = {
          ["family"] = str(val.family),
          ["given"] = str(val.given)
        }
        table.insert(auths, auth)
      end
    end
  }
end


local function highlight_author_name(auths)
  return {
    Div = function(el)
      if el.classes:includes("references") then
        return el:walk(highlight_author_filter(auths))
      end
      return nil
    end
  }
end

function Pandoc(doc)
  local bold_auth_name = {}
  doc:walk(get_auth_name(bold_auth_name))
  return doc:walk(highlight_author_name(bold_auth_name))
end
