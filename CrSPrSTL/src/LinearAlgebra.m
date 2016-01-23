function LinAlg = LinearAlgebra()
    % function: LinearAlgebra
    % Library with a set of linear algebra functions for rotation, etc.
    % that is used for defining dynamics, etc.
    
    LinAlg.SkewSymmetric_3Dim    = @SkewSymmetric_3Dim;
    LinAlg.zyx_Euler_RotationMat = @zyx_Euler_RotationMat;
    LinAlg.zyx_Ang_RateMat       = @zyx_Ang_RateMat;

    function SSMat = SkewSymmetric_3Dim(Vector)
        
        SSMat = [0          -Vector(3) Vector(2);...
                 Vector(3)  0          -Vector(1);...
                 -Vector(2) Vector(1)  0];
    end

    function R = zyx_Euler_RotationMat(Theta_Z,Theta_Y,Theta_X)
        R = [ c(Theta_Z)*c(Theta_Y)     c(Theta_Z)*s(Theta_Y)*s(Theta_X)-c(Theta_X)*s(Theta_Z)      s(Theta_Z)*s(Theta_X)+c(Theta_Z)*c(Theta_X)*s(Theta_Y);
              c(Theta_Y)*s(Theta_Z)     c(Theta_Z)*c(Theta_X)+s(Theta_Z)*s(Theta_Y)*s(Theta_X)      c(Theta_X)*s(Theta_Z)*s(Theta_Y)-c(Theta_Z)*s(Theta_X);
              -s(Theta_Y)               c(Theta_Y)*s(Theta_X)                                       c(Theta_Y)*c(Theta_X)];
        function r = c(a), r = cos(a); end
        function r = s(a), r = sin(a); end
    end

    function R = yx_RotationMat(Theta)
        R = [c(Theta) -s(Theta);
             s(Theta) c(Theta)];
        function r = c(a), r = cos(a); end
        function r = s(a), r = sin(a); end
    end

    function S = zyx_Ang_RateMat(Theta_Z,Theta_Y,Theta_X)
        S = (1/c(Theta_Y))*[c(Theta_Y)  s(Theta_X)*s(Theta_Y)   c(Theta_X)*s(Theta_Y);
                            0           c(Theta_X)*c(Theta_Y)   -s(Theta_X)*c(Theta_Y);
                            0           s(Theta_X)              c(Theta_X)];
        function r = c(a), r = cos(a); end
        function r = s(a), r = sin(a); end
    end
end