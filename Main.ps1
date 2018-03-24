#========================================================================
# Author 	: Kevin RAHETILAHY                                          #
#========================================================================

##############################################################
#                      LOAD ASSEMBLY                         #
##############################################################

[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')  				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('PresentationCore')      				| out-null
[System.Reflection.Assembly]::LoadFrom('assembly\MahApps.Metro.dll')       				| out-null
[System.Reflection.Assembly]::LoadFrom('assembly\System.Windows.Interactivity.dll') 	| out-null
[System.Windows.Forms.Application]::EnableVisualStyles()

##############################################################
#                      LOAD FUNCTION                         #
##############################################################
                      
function LoadXml ($Global:filename)
{
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}

# Load MainWindow
$XamlMainWindow=LoadXml(".\Main.xaml")
$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$Form=[Windows.Markup.XamlReader]::Load($Reader)

##############################################################
#              INCLUDE EXTERNAL SCRIPT                       #
##############################################################
$pathPanel= split-path -parent $MyInvocation.MyCommand.Definition
."$pathPanel\scripts\TrainScript.ps1"    
."$pathPanel\scripts\UIControl.ps1"  
                        
##############################################################
#                CONTROL INITIALIZATION                      #
##############################################################

# === Inside main xaml ===
$gridTrain       = $Form.FindName("trainGrid")
#$datagridTrain   = $Form.FindName("datagridTrain")

# ===  Window Resources   ==== 
# $ApplicationResources = $Form.Resources.MergedDictionaries


##############################################################
#                DATAS EXAMPLE                               #
##############################################################

 
$script:allTrains = (Get-gare -gare "La defense").idgare | Get-TrainDirection | %{ Get-NextTrain -idgare $_.idgare -traindirection $_.direction } 


# observablCollection is easier to handle :)
#$script:observableCollection = [System.Collections.ObjectModel.ObservableCollection[Object]]::new()


# Add datas to the datagrid
#$datagridTrain.ItemsSource = $Script:observableCollection

##############################################################
#                FUNCTIONS                                   #
##############################################################



##############################################################
#                MANAGE EVENT ON PANEL                       #
##############################################################


function Search_train(){
 
    $StackPanelmain = Create-StackPanel "StackPanelallTrains" "10,0,0,0" "Vertical" "Left" 
   
    
       
       foreach ($train in $allTrains ){       
       
            if ($train){      
                
                $trainIndex = $allTrains.IndexOf($train)

                $StackPanelparent  = [String]("StackPparent"+$trainIndex )
                $StackforPartition = [String]("StackForPart"+$trainIndex )

                $StackforPartition = Create-StackPanel  $StackforPartition "0,0,0,10" "Horizontal" "Left"
                $StackPanelparent  = Create-StackPanel  $StackPanelparent "10,0,0,0" "Vertical" "Left"  

                #======================= disk_n ==================================  
                $trainIndexLabel  = [String]("Disk_"+$trainIndex)
                $ChildSizeInfo   = [String]("Disk_"+$trainIndex +"_size" )
                $StackPaneldisk  = [String]("Disk_"+$trainIndex +"_stackP" )
     
                $StackPaneldisk  = Create-StackPanel  $StackPaneldisk  "0,0,0,0" "Horizontal" "Left"
                $trainIndexLabel  = Create-Label      $trainIndexLabel  "0,0,0,0"   
                $SizeInfoLabel   = Create-Label       $ChildSizeInfo   "0,0,0,0"
   

                $trainIndexLabel.Content = $trainHardDirveLabel+$train.direction 
                $SizeInfoLabel.Content  = $SizeDiskHardDirveLabel+ ($train.From) +" Go" 
                $StackPaneldisk.Children.Add($trainIndexLabel)  | out-Null
            
                $StackPanelparent.Children.Add($StackPaneldisk) | out-Null
                $StackPanelparent.Children.Add($SizeInfoLabel)  | out-Null
                
                $StackPanelparent.Background = "LightSlateGray"
                $StackforPartition.Children.Add($StackPanelparent) | out-Null

                $StackPanelmain.Children.Add($StackforPartition) | out-Null
            }
       }  
       $gridTrain.Children.Add($StackPanelmain)  | out-Null    
   }
   


##############################################################
#                SHOW WINDOW                                 #
##############################################################

Search_train

$Form.ShowDialog() | Out-Null

