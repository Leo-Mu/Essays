$d_s=g^{u_s}h^{v_s}$
$g^{a_s}h^{b_s}=g^{u_s}g^{y_rx_s}h^{b_s}h^{y_rx_s}$

```cpp
const len_q 160

typedef t_short bitset<len_q/2>;
typedef t_int bitset<len_q/2>;
typedef t_hash bitset<128>;

struct RT
{
    t_short xs,rs;
    bitset<64> info;
    t_short PVs;
};
struct MKT
{
    bitset<len_q> IDs,IDm1,ds;    //ds=g^us*h^vs
    t_short PVs;
    bitset<32> T_MKTs;
};
struct RQT  //request data
{
    t_hash Enc,Dec,Enc_d;
    bitset<464> R;
    // RQT(t_short data): R(AES128(s)) {}
};
struct ST
{
    t_hash hash_d;
    t_short Ds,Yr;

    ST()
};
struct RPT
{
    t_hash enc_t;
    ST st;
};
struct RVT
{
    t_int sig_pvk;
    t_int ID;
};
```

$$
F(x+y)=F(x)+F(y) \\
\\
F(x+a,y)=F(x,y)+F(a,y) \\
F(x,y+a)=F(x,y)+F(x,a) \\
F(x+\Delta x,y+\Delta y)=F(x,y)+F(\Delta x,y)+F(x,\Delta y)+F(\Delta x,\Delta y)
$$