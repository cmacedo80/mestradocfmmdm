/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package br.cfmm.dm;

import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
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
        try {
            System.out.println("br.cfmm.dm.RWrapper.<init>()");
            c = new RConnection();// make a new local connection on default port (6311)
            c.eval("rm(list=ls())");
            System.out.println("br.cfmm.dm.RWrapper.<init>() 0");
            c.eval("source(file = 'inicio.r')");
            System.out.println("br.cfmm.dm.RWrapper.<init>() 1");
            //org.rosuda.REngine.REXP x0 = c.eval("diretorio");
            //System.out.println("br.cfmm.dm.RWrapper.<init>() 2");
            //System.out.println(x0.asString());
            // c.eval("source(file = 'predict.r')");
        } catch (RserveException ex) {
            System.err.println(ex);
            Logger.getLogger(RWrapper.class.getName()).log(Level.SEVERE, null, ex);
        }
//        catch (REXPMismatchException ex) {
//            System.err.println(ex);
//            Logger.getLogger(RWrapper.class.getName()).log(Level.SEVERE, null, ex);
//        }
    }

    public List<Model> getPredicao(String texto) {
        List<Model> lista = new ArrayList<Model>();
        String [] linhas = texto.split("\n");
        
        try {
            RList l = new RList();
            System.out.println("br.cfmm.dm.RWrapper.getPredicao() 0");
            c.eval("rm(xpred)");
            
            c.assign("titulo", new REXPString(linhas));
            
            //c.eval("source(file = 'predict.r')");
            System.out.println("br.cfmm.dm.RWrapper.getPredicao() 1");
            c.eval("source(file = 'predict.r')");
            System.out.println("br.cfmm.dm.RWrapper.getPredicao() 2");
            org.rosuda.REngine.RFactor x0 = c.eval("xpred").asFactor();
            System.out.println("br.cfmm.dm.RWrapper.getPredicao() 3 size " + x0.size());
            
            for ( int i = 0 ; i < x0.size(); i++ )
            {
                System.out.println(x0.at(i));
                lista.add(new Model(linhas[i], x0.at(i)));
            }
            
            System.out.println("br.cfmm.dm.RWrapper.getPredicao() } ");
            
        } catch (REngineException e) {
            System.out.println(e);
            //manipulation
        } catch (REXPMismatchException ex) {
            System.out.println(ex);
            Logger.getLogger(RWrapper.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        return lista;
    }

}
