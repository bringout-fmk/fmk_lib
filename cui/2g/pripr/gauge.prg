
CREATE CLASS Gauge 
  
  EXPORTED:
  VAR cTitle
  
  VAR cColBorder
  VAR cColTitle
  
  VAR lSound
  
  VAR currentValue
  VAR endValue
  
  METHOD init(nCurrentValue, nEndValue, cColBorder, cColTitle, lSound )
  METHOD showProgress(nCurrentValue)
 
  PROTECTED:
     VAR oWindow
     
END CLASS


