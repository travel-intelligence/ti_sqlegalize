# encoding: utf-8

Fabricator(:user) do
  schemas ['MARKET', 'HR']
end

Fabricator(:user_market, class_name: User) do
  schemas ['MARKET']
end

Fabricator(:user_hr, class_name: User) do
  schemas ['HR']
end
