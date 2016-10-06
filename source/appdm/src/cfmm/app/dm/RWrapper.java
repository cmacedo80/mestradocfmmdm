/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package cfmm.app.dm;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import static javax.swing.JOptionPane.showMessageDialog;
import org.rosuda.REngine.REXPGenericVector;
import org.rosuda.REngine.REXPMismatchException;
import org.rosuda.REngine.REXPString;
import org.rosuda.REngine.REngineException;
import org.rosuda.REngine.RList;
import org.rosuda.REngine.Rserve.RConnection;
import org.rosuda.REngine.Rserve.RserveException;

/**
 *
 * @author m358869
 */
// http://stackoverflow.com/questions/10216014/how-to-make-a-simple-program-to-call-r-from-java-using-eclipse-and-rserve
public final class RWrapper {
    
    private static RWrapper singleton = new RWrapper( );
    
    private RConnection c;
    
    
    public static RWrapper getInstance( ) {
      return singleton;
   }
    private RWrapper()
    {
        
    }
    
    private void init()
    {
        System.out.println("br.cfmm.dm.RWrapper.init");
        
        
        try {
            System.err.println(">0");
            c = new RConnection();// make a new local connection on default port (6311)
            System.err.println(">0.5");
            c.eval("rm(list=ls())");
            System.err.println(">1");
            if ( Frontend.workfolder != null)
            {
                 c.eval("setwd('" + Frontend.workfolder + "')");
            }
            org.rosuda.REngine.REXP x0 = c.eval("getwd()");
            System.err.println(">2");
            //System.out.println("br.cfmm.dm.RWrapper.<init>() 2");
            System.out.println("Diretorio: " + x0.asString());
            System.err.println(">3");
            c.eval("source(file = 'javainicio.r')");
            System.err.println(">4");
            // c.eval("source(file = 'predict.r')");
        } catch (RserveException ex) {
            showMessageDialog(null, ex);
            System.err.println(ex);
            Logger.getLogger(RWrapper.class.getName()).log(Level.SEVERE, null, ex);
        }
        catch (REXPMismatchException ex) {
            showMessageDialog(null, ex);
            System.err.println(ex);
            Logger.getLogger(RWrapper.class.getName()).log(Level.SEVERE, null, ex);
        }
//        catch (REXPMismatchException ex) {
//            System.err.println(ex);
//            Logger.getLogger(RWrapper.class.getName()).log(Level.SEVERE, null, ex);
//        }
    }

    public List<Model> getPredicao(String texto) {
                
        System.out.println("br.cfmm.dm.RWrapper.getPredicao");
        
        List<Model> lista = new ArrayList<Model>();
        System.err.println(">>a");
        if ( c == null )
        {
            init();
        }
        System.err.println(">>b");
        if (c == null) {
            showMessageDialog(null, "Problemas na comunicação com o R");
        } else {
            String[] linhas = texto.split("\n");
            try {
                RList l = new RList();
                System.err.println(">>c");
                c.eval("rm(xpred)");
                System.err.println(">>d");
                c.assign("titulo", new REXPString(linhas));
                System.err.println(">>d");
                //c.eval("source(file = 'predict.r')");
                System.err.println(">>e");
                c.eval("source(file = 'javapredict.r')");
                System.err.println(">>f");
                org.rosuda.REngine.RFactor x0 = c.eval("xpred").asFactor();
                System.err.println(">>g");
                for (int i = 0; i < x0.size(); i++) {
                    lista.add(new Model(linhas[i], x0.at(i)));
                }
            } catch (REngineException e) {
                c.close();
                c = null;
                showMessageDialog(null, e);
                System.out.println(e);
                //manipulation
            } catch (REXPMismatchException ex) {
                c.close();
                c = null;
                showMessageDialog(null, ex);
                System.out.println(ex);
                Logger.getLogger(RWrapper.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        System.err.println(">>z");

        return lista;
    }

}
