# 
# 
# dat %>% 
#     group_by(model) %>% 
#     filter( year == 2018) %>% 
#     summarise( p = mean(price))
# 
# dat %>% 
#     filter( str_detect(title, "Zetec"))  %>% 
#     group_by(title) %>% 
#     tally() %>% 
#     arrange(desc(n))
# 
# 
# ggplot( data = dat , aes(x=age , y = price, col = model, group = model)) +
#     geom_point() + 
#     geom_smooth() +
#     theme_bw() +
#     scale_x_continuous(breaks = pretty_breaks(10)) +
#     scale_y_continuous(breaks = pretty_breaks(10)) 
# 
# 
# 
# tdat <- dat_mod %>% 
#     filter(model == "civic") %>% 
#     filter(fuel_type == "Petrol") %>% 
#     filter( age == 1) %>% 
#     mutate(price = exp(logprice)) %>% 
#     select(price, everything())
# 
# 
# tdat$price %>% mean
