function E2=Energy2_3D_QPOTTS(IESM_NewSpin)
E2=26-KDel_3D_QPOTTS(IESM_NewSpin(2,2,2),IESM_NewSpin(1,1,1))+...
KDel_3D_QPOTTS(IESM_NewSpin(2,2,2),IESM_NewSpin(1,2,1))+...
KDel_3D_QPOTTS(IESM_NewSpin(2,2,2),IESM_NewSpin(1,3,1))+...
KDel_3D_QPOTTS(IESM_NewSpin(2,2,2),IESM_NewSpin(2,3,1))+...
KDel_3D_QPOTTS(IESM_NewSpin(2,2,2),IESM_NewSpin(3,3,1))+...
KDel_3D_QPOTTS(IESM_NewSpin(2,2,2),IESM_NewSpin(3,2,1))+...
KDel_3D_QPOTTS(IESM_NewSpin(2,2,2),IESM_NewSpin(3,1,1))+...
KDel_3D_QPOTTS(IESM_NewSpin(2,2,2),IESM_NewSpin(2,1,1))+...
KDel_3D_QPOTTS(IESM_NewSpin(2,2,2),IESM_NewSpin(1,1,2))+...
KDel_3D_QPOTTS(IESM_NewSpin(2,2,2),IESM_NewSpin(1,2,2))+...
KDel_3D_QPOTTS(IESM_NewSpin(2,2,2),IESM_NewSpin(1,3,2))+...
KDel_3D_QPOTTS(IESM_NewSpin(2,2,2),IESM_NewSpin(2,3,2))+...
KDel_3D_QPOTTS(IESM_NewSpin(2,2,2),IESM_NewSpin(3,3,2))+...
KDel_3D_QPOTTS(IESM_NewSpin(2,2,2),IESM_NewSpin(3,2,2))+...
KDel_3D_QPOTTS(IESM_NewSpin(2,2,2),IESM_NewSpin(3,1,2))+...
KDel_3D_QPOTTS(IESM_NewSpin(2,2,2),IESM_NewSpin(2,1,2))+...
KDel_3D_QPOTTS(IESM_NewSpin(2,2,2),IESM_NewSpin(2,2,2))+...
KDel_3D_QPOTTS(IESM_NewSpin(2,2,2),IESM_NewSpin(1,1,3))+...
KDel_3D_QPOTTS(IESM_NewSpin(2,2,2),IESM_NewSpin(1,2,3))+...
KDel_3D_QPOTTS(IESM_NewSpin(2,2,2),IESM_NewSpin(1,3,3))+...
KDel_3D_QPOTTS(IESM_NewSpin(2,2,2),IESM_NewSpin(2,3,3))+...
KDel_3D_QPOTTS(IESM_NewSpin(2,2,2),IESM_NewSpin(3,3,3))+...
KDel_3D_QPOTTS(IESM_NewSpin(2,2,2),IESM_NewSpin(3,2,3))+...
KDel_3D_QPOTTS(IESM_NewSpin(2,2,2),IESM_NewSpin(3,1,3))+...
KDel_3D_QPOTTS(IESM_NewSpin(2,2,2),IESM_NewSpin(2,1,3));