removed block

if we want some reosurce to stop managed by the terraform
then we can use removed block

it will remove the reosurce from the state 
but it will not touch the real infrastructure

for example

if we delete the resource from our .tf file then plan will show
that 1 resource to destroy
but we dont want that to be destroyed we just want to control that
resource manually by going into the cloud platform instead of managing by
terraform code 

so we just add the remove blcok and specify the resource and it will not
manage it and it will delete it from its state 


by default it will remove from state and also destory the infrastructure

so you need to specify the destroy = false to not destroy just telling the 
terraform to forget about it.

for this you need to delerte the reosurce block from your cofiguration
or comment it out so that terrafomr doesn't get confuse

afte the use you can delete the removed block from the configuration
or not delete it amd keep it for documentation.

explain in deatil and add yolur knowledge and give real world examples to make it more undersatndable